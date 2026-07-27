import Foundation

struct DeleteCommentUseCase: Sendable {
    private let commentRepository: CommentRepository

    init(commentRepository: CommentRepository) {
        self.commentRepository = commentRepository
    }

    func execute(commentID: UUID) async throws {
        try await commentRepository.deleteComment(id: commentID)
    }
}
