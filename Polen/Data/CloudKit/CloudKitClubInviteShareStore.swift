import CloudKit
import Foundation

struct CloudKitPreparedClubShare {
    let share: CKShare
    let container: CKContainer
}

@MainActor
final class CloudKitClubInviteShareStore {
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private let sharedDatabase: CKDatabase

    init(containerProvider: CloudKitContainerProviding) {
        self.container = containerProvider.container()
        self.privateDatabase = containerProvider.database(for: .private)
        self.sharedDatabase = containerProvider.database(for: .shared)
    }

    func prepareShare(for summary: HomeClubSummary) async throws -> CloudKitPreparedClubShare {
        let rootRecord = try await inviteRecord(for: summary)

        if let share = try await existingShare(for: rootRecord) {
            return CloudKitPreparedClubShare(share: share, container: container)
        }

        let share = CKShare(rootRecord: rootRecord)
        share[CKShare.SystemFieldKey.title] = "Convite para \(summary.clubName)" as CKRecordValue
        share[CKShare.SystemFieldKey.shareType] = "clubInvite" as CKRecordValue

        try await save(records: [rootRecord, share])
        return CloudKitPreparedClubShare(share: share, container: container)
    }

    func acceptShare(metadata: CKShare.Metadata) async throws -> String {
        try await accept(metadata: metadata)

        let rootRecord = try await sharedDatabase.record(for: metadata.rootRecordID)

        guard let inviteCode = rootRecord[CloudKitField.ClubInviteShare.inviteCode] as? String,
              !inviteCode.trimmed.isEmpty else {
            throw CloudKitRecordMappingError.missingField(CloudKitField.ClubInviteShare.inviteCode)
        }

        return inviteCode
    }

    private func inviteRecord(for summary: HomeClubSummary) async throws -> CKRecord {
        let recordID = CKRecord.ID(recordName: "ClubInviteShare-\(summary.id.uuidString)")
        let record: CKRecord

        do {
            record = try await privateDatabase.record(for: recordID)
        } catch {
            if error.isMissingCloudKitRecord {
                record = CKRecord(recordType: CloudKitRecordType.clubInviteShare, recordID: recordID)
            } else {
                throw error
            }
        }

        record[CloudKitField.Shared.id] = summary.id.uuidString
        record[CloudKitField.ClubInviteShare.clubID] = summary.id.uuidString
        record[CloudKitField.ClubInviteShare.clubName] = summary.clubName
        record[CloudKitField.ClubInviteShare.inviteCode] = summary.inviteCode
        record[CloudKitField.ClubInviteShare.createdAt] = Date()

        return record
    }

    private func existingShare(for rootRecord: CKRecord) async throws -> CKShare? {
        guard let shareReference = rootRecord.share else {
            return nil
        }

        return try await privateDatabase.record(for: shareReference.recordID) as? CKShare
    }

    private func save(records: [CKRecord]) async throws {
        try await withCheckedThrowingContinuation { continuation in
            let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
            operation.savePolicy = .changedKeys
            operation.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            privateDatabase.add(operation)
        }
    }

    private func accept(metadata: CKShare.Metadata) async throws {
        try await withCheckedThrowingContinuation { continuation in
            let operation = CKAcceptSharesOperation(shareMetadatas: [metadata])
            operation.acceptSharesResultBlock = { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            container.add(operation)
        }
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
