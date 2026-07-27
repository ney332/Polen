import Foundation

struct UpdateCommentUseCase: Sendable {
    private let commentRepository: CommentRepository

    init(commentRepository: CommentRepository) {
        self.commentRepository = commentRepository
    }

    func execute(comment: Comment, body: String) async throws -> Comment {
        let trimmedBody = body.trimmed

        guard !trimmedBody.isEmpty else {
            throw DomainError.emptyComment
        }

        var updatedComment = comment
        updatedComment.body = trimmedBody

        try await commentRepository.updateComment(updatedComment)

        return updatedComment
    }
}
