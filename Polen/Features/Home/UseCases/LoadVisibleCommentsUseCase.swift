import Foundation

struct LoadVisibleCommentsUseCase: Sendable {
    private let commentRepository: CommentRepository
    private let visibleCommentsUseCase = VisibleCommentsUseCase()

    init(commentRepository: CommentRepository) {
        self.commentRepository = commentRepository
    }

    func execute(clubID: UUID, readingProgress: ReadingProgress) async throws -> [Comment] {
        let comments = try await commentRepository.comments(for: clubID)
        return visibleCommentsUseCase.execute(
            comments: comments,
            readingProgress: readingProgress
        )
    }
}
