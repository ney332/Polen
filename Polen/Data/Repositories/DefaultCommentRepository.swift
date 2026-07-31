import Foundation

actor DefaultCommentRepository: CommentRepository {
    private let cloudKitStore: CloudKitCommentStoring

    init(cloudKitStore: CloudKitCommentStoring) {
        self.cloudKitStore = cloudKitStore
    }

    func comments(for clubID: UUID, bookID: UUID) async throws -> [Comment] {
        try await cloudKitStore.comments(for: clubID, bookID: bookID)
    }

    func createComment(_ comment: Comment) async throws {
        guard !comment.body.trimmed.isEmpty else {
            throw DomainError.emptyComment
        }

        try await cloudKitStore.createComment(comment)
    }

    func updateComment(_ comment: Comment) async throws {
        guard !comment.body.trimmed.isEmpty else {
            throw DomainError.emptyComment
        }

        try await cloudKitStore.updateComment(comment)
    }

    func deleteComment(id: UUID) async throws {
        try await cloudKitStore.deleteComment(id: id)
    }

    func replies(for commentID: UUID) async throws -> [Reply] {
        try await cloudKitStore.replies(for: commentID)
    }

    func createReply(_ reply: Reply) async throws {
        guard !reply.body.trimmed.isEmpty else {
            throw DomainError.emptyComment
        }

        try await cloudKitStore.createReply(reply)
    }
}
