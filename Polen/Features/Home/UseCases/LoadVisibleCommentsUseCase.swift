import Foundation

struct LoadVisibleCommentsUseCase: Sendable {
    private let commentRepository: CommentRepository

    init(commentRepository: CommentRepository) {
        self.commentRepository = commentRepository
    }

    func execute(clubID: UUID, readingProgress: ReadingProgress) async throws -> [Comment] {
        try await commentRepository.comments(for: clubID, bookID: readingProgress.bookID)
    }
}
