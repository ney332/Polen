import CloudKit
import Foundation

protocol CloudKitClubHomeStoring: Sendable {
    func currentSummary(for userID: UUID) async throws -> HomeClubSummary?
    func summary(for clubID: UUID, userID: UUID) async throws -> HomeClubSummary
}

protocol CloudKitReadingProgressStoring: Sendable {
    func updateProgress(_ progress: ReadingProgress) async throws -> ReadingProgress
}

actor CloudKitClubHomeStore: CloudKitClubHomeStoring, CloudKitReadingProgressStoring {
    private let publicDatabase: CKDatabase
    private let privateDatabase: CKDatabase

    init(containerProvider: CloudKitContainerProviding) {
        self.publicDatabase = containerProvider.database(for: .public)
        self.privateDatabase = containerProvider.database(for: .private)
    }

    func currentSummary(for userID: UUID) async throws -> HomeClubSummary? {
        guard let membership = try await membership(for: userID) else {
            return nil
        }

        return try await summary(for: membership.clubID, userID: userID)
    }

    func summary(for clubID: UUID, userID: UUID) async throws -> HomeClubSummary {
        let club = try await fetchClub(id: clubID)
        let book = try await fetchBook(id: club.activeBookID)
        let progress = try await readingProgress(for: userID, clubID: clubID)
        let memberCount = try await memberCount(for: clubID)

        return HomeClubSummary(
            id: club.id,
            clubName: club.name,
            photoAssetName: club.photoAssetName,
            inviteCode: club.inviteCode,
            activeBook: book,
            readingProgress: progress,
            memberCount: memberCount
        )
    }

    func updateProgress(_ progress: ReadingProgress) async throws -> ReadingProgress {
        let recordID = CKRecord.ID(recordName: progress.id)
        let record = try await privateDatabase.record(for: recordID)
        record.update(with: progress)
        _ = try await privateDatabase.save(record)

        return progress
    }

    private func fetchClub(id: UUID) async throws -> BookClub {
        let record = try await publicDatabase.record(for: CKRecord.ID(recordName: id))
        return try BookClub(record: record)
    }

    private func fetchBook(id: UUID) async throws -> Book {
        let record = try await publicDatabase.record(for: CKRecord.ID(recordName: id))
        return try Book(record: record)
    }

    private func readingProgress(for userID: UUID, clubID: UUID) async throws -> ReadingProgress {
        let predicate = NSPredicate(
            format: "%K == %@ AND %K == %@",
            CloudKitField.ReadingProgress.userID,
            userID.uuidString,
            CloudKitField.ReadingProgress.clubID,
            clubID.uuidString
        )
        let query = CKQuery(recordType: CloudKitRecordType.readingProgress, predicate: predicate)
        let records = try await queryRecords(matching: query, in: privateDatabase, limit: 1)

        guard let record = records.first else {
            throw DomainError.invalidReadingProgress
        }

        return try ReadingProgress(record: record)
    }

    private func memberCount(for clubID: UUID) async throws -> Int {
        let predicate = NSPredicate(format: "%K == %@", CloudKitField.Membership.clubID, clubID.uuidString)
        let query = CKQuery(recordType: CloudKitRecordType.membership, predicate: predicate)

        do {
            return try await queryRecords(matching: query, in: publicDatabase, limit: 50).count
        } catch {
            if error.isMissingCloudKitRecordType {
                return 0
            }

            throw error
        }
    }

    private func membership(for userID: UUID) async throws -> Membership? {
        let predicate = NSPredicate(format: "%K == %@", CloudKitField.Membership.userID, userID.uuidString)
        let query = CKQuery(recordType: CloudKitRecordType.membership, predicate: predicate)

        do {
            guard let record = try await queryRecords(matching: query, in: publicDatabase, limit: 1).first else {
                return nil
            }

            return try Membership(record: record)
        } catch {
            if error.isMissingCloudKitRecordType {
                return nil
            }

            throw error
        }
    }

    private func queryRecords(matching query: CKQuery, in database: CKDatabase, limit: Int) async throws -> [CKRecord] {
        let result = try await database.records(matching: query, resultsLimit: limit)

        return try result.matchResults.compactMap { _, recordResult in
            try recordResult.get()
        }
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
