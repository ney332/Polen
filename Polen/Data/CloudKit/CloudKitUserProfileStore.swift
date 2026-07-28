import CloudKit
import Foundation

protocol CloudKitUserProfileStoring: Sendable {
    func profile(for userID: UUID) async throws -> UserProfile?
    func save(_ profile: UserProfile) async throws
}

actor CloudKitUserProfileStore: CloudKitUserProfileStoring {
    private let privateDatabase: CKDatabase

    init(containerProvider: CloudKitContainerProviding) {
        self.privateDatabase = containerProvider.database(for: .private)
    }

    func profile(for userID: UUID) async throws -> UserProfile? {
        do {
            let record = try await privateDatabase.record(for: CKRecord.ID(recordName: userID))
            return try UserProfile(record: record)
        } catch {
            if error.isMissingCloudKitRecord {
                return nil
            }

            throw error
        }
    }

    func save(_ profile: UserProfile) async throws {
        let recordID = CKRecord.ID(recordName: profile.id)
        let record: CKRecord

        do {
            record = try await privateDatabase.record(for: recordID)
        } catch {
            if error.isMissingCloudKitRecord {
                record = CKRecord(recordType: CloudKitRecordType.userProfile, recordID: recordID)
            } else {
                throw error
            }
        }

        try record.update(with: profile)
        _ = try await privateDatabase.save(record)
    }
}

private extension Error {
    var isMissingCloudKitRecord: Bool {
        guard let ckError = self as? CKError else {
            return false
        }

        return ckError.code == .unknownItem
    }
}
