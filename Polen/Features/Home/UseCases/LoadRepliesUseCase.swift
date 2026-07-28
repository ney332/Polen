import Foundation

struct LoadRepliesUseCase: Sendable {
    private let commentRepository: CommentRepository

    init(commentRepository: CommentRepository) {
        self.commentRepository = commentRepository
    }

    func execute(commentID: UUID) async throws -> [Reply] {
        try await commentRepository.replies(for: commentID)
    }
}
