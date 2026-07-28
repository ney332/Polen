import CloudKit
import Foundation

protocol CloudKitBookClubStoring: Sendable {
    func currentClub(for userID: UUID) async throws -> BookClub?
    func createClub(_ club: BookClub, book: Book, ownerID: UUID) async throws
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

    func createClub(_ club: BookClub, book: Book, ownerID: UUID) async throws {
        guard try await currentClub(for: ownerID) == nil else {
            throw DomainError.userAlreadyHasClub
        }

        let membership = Membership(userID: ownerID, clubID: club.id, role: .owner)
        let progress = ReadingProgress(userID: ownerID, clubID: club.id, bookID: book.id)

        _ = try await publicDatabase.save(CKRecord(book: book))
        _ = try await publicDatabase.save(CKRecord(bookClub: club))
        _ = try await publicDatabase.save(CKRecord(membership: membership))
        _ = try await privateDatabase.save(CKRecord(readingProgress: progress))
    }

    func joinClub(inviteCode: String, userID: UUID) async throws -> BookClub {
        guard try await currentClub(for: userID) == nil else {
            throw DomainError.userAlreadyHasClub
        }

        let code = inviteCode.normalizedInviteCode
        let predicate = NSPredicate(format: "%K == %@", CloudKitField.BookClub.inviteCode, code)
        let query = CKQuery(recordType: CloudKitRecordType.bookClub, predicate: predicate)
        let records: [CKRecord]

        do {
            records = try await queryRecords(matching: query, in: publicDatabase, limit: 1)
        } catch {
            if error.isMissingCloudKitRecordType {
                throw DomainError.invalidInviteCode
            }

            throw error
        }

        guard let record = records.first else {
            throw DomainError.invalidInviteCode
        }

        let club = try BookClub(record: record)
        let membership = Membership(userID: userID, clubID: club.id)
        let progress = ReadingProgress(userID: userID, clubID: club.id, bookID: club.activeBookID)

        _ = try await publicDatabase.save(CKRecord(membership: membership))
        _ = try await privateDatabase.save(CKRecord(readingProgress: progress))

        return club
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
}

private extension Error {
    var isMissingCloudKitRecordType: Bool {
        guard let ckError = self as? CKError else {
            return false
        }

        return ckError.code == .unknownItem
    }
}
