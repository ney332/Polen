import CloudKit
import Foundation

protocol CloudKitCommentStoring: Sendable {
    func comments(for clubID: UUID) async throws -> [Comment]
    func createComment(_ comment: Comment) async throws
    func updateComment(_ comment: Comment) async throws
    func deleteComment(id: UUID) async throws
}

actor CloudKitCommentStore: CloudKitCommentStoring {
    private let publicDatabase: CKDatabase

    init(containerProvider: CloudKitContainerProviding) {
        self.publicDatabase = containerProvider.database(for: .public)
    }

    func comments(for clubID: UUID) async throws -> [Comment] {
        let predicate = NSPredicate(format: "%K == %@", CloudKitField.Comment.clubID, clubID.uuidString)
        let query = CKQuery(recordType: CloudKitRecordType.comment, predicate: predicate)
        query.sortDescriptors = [
            NSSortDescriptor(key: CloudKitField.Comment.createdAt, ascending: true)
        ]

        do {
            let result = try await publicDatabase.records(matching: query, resultsLimit: 100)
            return try result.matchResults.map { _, recordResult in
                try Comment(record: recordResult.get())
            }
        } catch {
            if error.isMissingCloudKitRecordType {
                return []
            }

            throw error
        }
    }

    func createComment(_ comment: Comment) async throws {
        _ = try await publicDatabase.save(CKRecord(comment: comment))
    }

    func updateComment(_ comment: Comment) async throws {
        let record = try await publicDatabase.record(for: CKRecord.ID(recordName: comment.id))
        record.update(with: comment)
        _ = try await publicDatabase.save(record)
    }

    func deleteComment(id: UUID) async throws {
        _ = try await publicDatabase.deleteRecord(withID: CKRecord.ID(recordName: id))
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
