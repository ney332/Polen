import Foundation

struct CreateReplyUseCase: Sendable {
    private let commentRepository: CommentRepository

    init(commentRepository: CommentRepository) {
        self.commentRepository = commentRepository
    }

    func execute(commentID: UUID, authorID: UUID, body: String) async throws -> Reply {
        let trimmedBody = body.trimmed

        guard !trimmedBody.isEmpty else {
            throw DomainError.emptyComment
        }

        let reply = Reply(
            commentID: commentID,
            authorID: authorID,
            body: trimmedBody
        )

        try await commentRepository.createReply(reply)

        return reply
    }
}
