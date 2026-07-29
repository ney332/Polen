import Foundation

struct LoadVisibleCommentsUseCase: Sendable {
    private let commentRepository: CommentRepository

    init(commentRepository: CommentRepository) {
        self.commentRepository = commentRepository
    }

    func execute(clubID: UUID, readingProgress _: ReadingProgress) async throws -> [Comment] {
        try await commentRepository.comments(for: clubID)
    }
}
