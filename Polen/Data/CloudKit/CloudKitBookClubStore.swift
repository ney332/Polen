import CloudKit
import Foundation

protocol CloudKitBookClubStoring: Sendable {
    func currentClub(for userID: UUID) async throws -> BookClub?
    func createClub(_ club: BookClub, book: Book?, ownerID: UUID) async throws
    func setActiveBook(_ book: Book, forClubID clubID: UUID, userID: UUID) async throws -> BookClub
    func bookShelf(forClubID clubID: UUID) async throws -> [ClubBookShelfItem]
    func joinClub(inviteCode: String, userID: UUID) async throws -> BookClub
    func leaveClub(userID: UUID) async throws
}

actor CloudKitBookClubStore: CloudKitBookClubStoring {
    private let publicDatabase: CKDatabase
    private let privateDatabase: CKDatabase

    init(containerProvider: CloudKitContainerProviding) {
        self.publicDatabase = containerProvider.database(for: .public)
        self.privateDatabase = containerProvider.database(for: .private)
    }

    func currentClub(for userID: UUID) async throws -> BookClub? {
        guard let membership = try await membership(for: userID) else {
            return nil
        }

        return try await fetchClub(id: membership.clubID)
    }

    func createClub(_ club: BookClub, book: Book?, ownerID: UUID) async throws {
        guard try await currentClub(for: ownerID) == nil else {
            throw DomainError.userAlreadyHasClub
        }

        let membership = Membership(userID: ownerID, clubID: club.id, role: .owner)

        if let book {
            _ = try await publicDatabase.save(CKRecord(book: book))
            try await saveBookShelfItemIfPossible(book: book, clubID: club.id, activeBookID: book.id)
            let progress = ReadingProgress(userID: ownerID, clubID: club.id, bookID: book.id)
            _ = try await privateDatabase.save(CKRecord(readingProgress: progress))
        }

        _ = try await publicDatabase.save(CKRecord(bookClub: club))
        _ = try await publicDatabase.save(CKRecord(membership: membership))
    }

    func setActiveBook(_ book: Book, forClubID clubID: UUID, userID: UUID) async throws -> BookClub {
        _ = try await publicDatabase.save(CKRecord(book: book))

        let record = try await publicDatabase.record(for: CKRecord.ID(recordName: clubID))
        var club = try BookClub(record: record)
        club.activeBookID = book.id
        record.update(with: club)
        _ = try await publicDatabase.save(record)
        try await saveBookShelfItemIfPossible(book: book, clubID: clubID, activeBookID: book.id)

        try await upsertReadingProgress(userID: userID, clubID: clubID, bookID: book.id)

        return club
    }

    func bookShelf(forClubID clubID: UUID) async throws -> [ClubBookShelfItem] {
        let club = try await fetchClub(id: clubID)
        let predicate = NSPredicate(format: "%K == %@", CloudKitField.ClubBookHistory.clubID, clubID.uuidString)
        let query = CKQuery(recordType: CloudKitRecordType.clubBookHistory, predicate: predicate)
        query.sortDescriptors = [
            NSSortDescriptor(key: CloudKitField.ClubBookHistory.startedAt, ascending: false)
        ]

        let records: [CKRecord]

        do {
            records = try await queryRecords(matching: query, in: publicDatabase, limit: 50)
        } catch {
            if !error.isMissingCloudKitRecordType {
                throw error
            }

            records = []
        }

        var items: [ClubBookShelfItem] = []

        for record in records {
            guard let bookID = record.optionalUUID(for: CloudKitField.ClubBookHistory.bookID),
                  let book = try? await fetchBook(id: bookID) else {
                continue
            }

            items.append(
                ClubBookShelfItem(
                    id: record.recordID.recordName,
                    clubID: clubID,
                    book: book,
                    startedAt: record.optionalDate(for: CloudKitField.ClubBookHistory.startedAt) ?? .now,
                    isActive: bookID == club.activeBookID
                )
            )
        }

        let commentBookIDs = try await commentBookIDs(forClubID: clubID)
        for bookID in commentBookIDs where !items.contains(where: { $0.book.id == bookID }) {
            guard let book = try? await fetchBook(id: bookID) else {
                continue
            }

            items.append(
                ClubBookShelfItem(
                    clubID: clubID,
                    book: book,
                    isActive: bookID == club.activeBookID
                )
            )
        }

        if let activeBookID = club.activeBookID,
           !items.contains(where: { $0.book.id == activeBookID }),
           let book = try? await fetchBook(id: activeBookID) {
            items.insert(
                ClubBookShelfItem(
                    clubID: clubID,
                    book: book,
                    startedAt: club.createdAt,
                    isActive: true
                ),
                at: 0
            )
        }

        return items
    }

    func joinClub(inviteCode: String, userID: UUID) async throws -> BookClub {
        guard try await currentClub(for: userID) == nil else {
            throw DomainError.userAlreadyHasClub
        }

        guard let record = try await firstClubRecord(inviteCode: inviteCode) else {
            throw DomainError.invalidInviteCode
        }

        let club = try BookClub(record: record)
        let membership = Membership(userID: userID, clubID: club.id)

        _ = try await publicDatabase.save(CKRecord(membership: membership))

        if let activeBookID = club.activeBookID {
            try await upsertReadingProgress(userID: userID, clubID: club.id, bookID: activeBookID)
        }

        return club
    }

    private func firstClubRecord(inviteCode: String) async throws -> CKRecord? {
        for code in inviteCode.inviteCodeQueryVariants {
            let predicate = NSPredicate(format: "%K == %@", CloudKitField.BookClub.inviteCode, code)
            let query = CKQuery(recordType: CloudKitRecordType.bookClub, predicate: predicate)

            do {
                if let record = try await queryRecords(matching: query, in: publicDatabase, limit: 1).first {
                    return record
                }
            } catch {
                if error.isMissingCloudKitRecordType {
                    return nil
                }

                throw error
            }
        }

        return nil
    }

    func leaveClub(userID: UUID) async throws {
        guard let membership = try await membership(for: userID) else {
            return
        }

        _ = try await publicDatabase.deleteRecord(withID: CKRecord.ID(recordName: membership.id))
        try await deleteReadingProgress(userID: userID, clubID: membership.clubID)
    }

    private func membership(for userID: UUID) async throws -> Membership? {
        let predicate = NSPredicate(format: "%K == %@", CloudKitField.Membership.userID, userID.uuidString)
        let query = CKQuery(recordType: CloudKitRecordType.membership, predicate: predicate)
        let records: [CKRecord]

        do {
            records = try await queryRecords(matching: query, in: publicDatabase, limit: 1)
        } catch {
            if error.isMissingCloudKitRecordType {
                return nil
            }

            throw error
        }

        guard let record = records.first else {
            return nil
        }

        return try Membership(record: record)
    }

    private func fetchClub(id: UUID) async throws -> BookClub {
        let recordID = CKRecord.ID(recordName: id)
        let record = try await publicDatabase.record(for: recordID)
        return try BookClub(record: record)
    }

    private func fetchBook(id: UUID) async throws -> Book {
        let record = try await publicDatabase.record(for: CKRecord.ID(recordName: id))
        return try Book(record: record)
    }

    private func commentBookIDs(forClubID clubID: UUID) async throws -> [UUID] {
        let predicate = NSPredicate(format: "%K == %@", CloudKitField.Comment.clubID, clubID.uuidString)
        let query = CKQuery(recordType: CloudKitRecordType.comment, predicate: predicate)

        do {
            let records = try await queryRecords(matching: query, in: publicDatabase, limit: 100)
            return Array(Set(records.compactMap { $0.optionalUUID(for: CloudKitField.Comment.bookID) }))
        } catch {
            if error.isMissingCloudKitRecordType {
                return []
            }

            throw error
        }
    }

    private func saveBookShelfItemIfPossible(book: Book, clubID: UUID, activeBookID: UUID?) async throws {
        let item = ClubBookShelfItem(
            clubID: clubID,
            book: book,
            isActive: book.id == activeBookID
        )

        do {
            _ = try await publicDatabase.save(CKRecord(clubBookShelfItem: item))
        } catch {
            if !error.isMissingCloudKitRecordType {
                throw error
            }
        }
    }

    private func deleteReadingProgress(userID: UUID, clubID: UUID) async throws {
        let predicate = NSPredicate(
            format: "%K == %@ AND %K == %@",
            CloudKitField.ReadingProgress.userID,
            userID.uuidString,
            CloudKitField.ReadingProgress.clubID,
            clubID.uuidString
        )
        let query = CKQuery(recordType: CloudKitRecordType.readingProgress, predicate: predicate)
        let records: [CKRecord]

        do {
            records = try await queryRecords(matching: query, in: privateDatabase, limit: 10)
        } catch {
            if error.isMissingCloudKitRecordType {
                return
            }

            throw error
        }

        for record in records {
            _ = try await privateDatabase.deleteRecord(withID: record.recordID)
        }
    }

    private func upsertReadingProgress(userID: UUID, clubID: UUID, bookID: UUID) async throws {
        let predicate = NSPredicate(
            format: "%K == %@ AND %K == %@",
            CloudKitField.ReadingProgress.userID,
            userID.uuidString,
            CloudKitField.ReadingProgress.clubID,
            clubID.uuidString
        )
        let query = CKQuery(recordType: CloudKitRecordType.readingProgress, predicate: predicate)

        do {
            if let record = try await queryRecords(matching: query, in: privateDatabase, limit: 1).first {
                let existingProgress = try ReadingProgress(record: record)
                let progress = ReadingProgress(
                    id: existingProgress.id,
                    userID: userID,
                    clubID: clubID,
                    bookID: bookID
                )
                record.update(with: progress)
                _ = try await privateDatabase.save(record)
                return
            }
        } catch {
            if !error.isMissingCloudKitRecordType {
                throw error
            }
        }

        let progress = ReadingProgress(userID: userID, clubID: clubID, bookID: bookID)
        _ = try await privateDatabase.save(CKRecord(readingProgress: progress))
    }

    private func queryRecords(matching query: CKQuery, in database: CKDatabase, limit: Int) async throws -> [CKRecord] {
        let result = try await database.records(matching: query, resultsLimit: limit)

        return try result.matchResults.compactMap { _, recordResult in
            try recordResult.get()
        }
    }
}

private extension String {
    var normalizedInviteCode: String {
        trimmed
            .uppercased()
            .filter { $0.isLetter || $0.isNumber }
    }

    var inviteCodeQueryVariants: [String] {
        let trimmedCode = trimmed.uppercased()
        let normalizedCode = normalizedInviteCode
        var variants = [trimmedCode, normalizedCode]

        if normalizedCode.count > 4 {
            let splitIndex = normalizedCode.index(normalizedCode.endIndex, offsetBy: -4)
            variants.append("\(normalizedCode[..<splitIndex])-\(normalizedCode[splitIndex...])")
        }

        return Array(Set(variants)).filter { !$0.isEmpty }
    }
}

private extension CKRecord {
    func optionalUUID(for field: String) -> UUID? {
        (self[field] as? String).flatMap(UUID.init(uuidString:))
    }

    func optionalDate(for field: String) -> Date? {
        self[field] as? Date
    }
}

private extension Error {
    var isMissingCloudKitRecordType: Bool {
        guard let ckError = self as? CKError else {
            return false
        }

        return ckError.code == .unknownItem
    }
}
