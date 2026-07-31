import Foundation

struct LoadBookCommentsUseCase: Sendable {
    private let commentRepository: CommentRepository

    init(commentRepository: CommentRepository) {
        self.commentRepository = commentRepository
    }

    func execute(clubID: UUID, bookID: UUID) async throws -> [Comment] {
        try await commentRepository.comments(for: clubID, bookID: bookID)
    }
}
