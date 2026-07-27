import Foundation

struct CreateCommentUseCase: Sendable {
    private let commentRepository: CommentRepository

    init(commentRepository: CommentRepository) {
        self.commentRepository = commentRepository
    }

    func execute(clubID: UUID, authorID: UUID, body: String, pageReference: Int) async throws -> Comment {
        let trimmedBody = body.trimmed

        guard !trimmedBody.isEmpty else {
            throw DomainError.emptyComment
        }

        let comment = Comment(
            clubID: clubID,
            authorID: authorID,
            body: trimmedBody,
            pageReference: pageReference
        )

        try await commentRepository.createComment(comment)

        return comment
    }
}
