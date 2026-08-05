import Foundation

struct CreateCommentUseCase: Sendable {
    private let commentRepository: CommentRepository

    init(commentRepository: CommentRepository) {
        self.commentRepository = commentRepository
    }

    func execute(
        clubID: UUID,
        bookID: UUID,
        author: UserProfile,
        body: String,
        audio: AudioAttachment?,
        pageReference: Int
    ) async throws -> Comment {
        let trimmedBody = body.trimmed

        guard !trimmedBody.isEmpty || audio != nil else {
            throw DomainError.emptyComment
        }

        let comment = Comment(
            clubID: clubID,
            bookID: bookID,
            authorID: author.id,
            authorDisplayName: author.displayName,
            authorAvatarAssetName: author.avatarAssetName,
            authorAvatarImageData: author.avatarImageData,
            body: trimmedBody,
            audioData: audio?.data,
            audioDuration: audio?.duration,
            pageReference: pageReference
        )

        try await commentRepository.createComment(comment)

        return comment
    }
}
