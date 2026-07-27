import Foundation

struct VisibleCommentsUseCase: Sendable {
    private let isCommentVisibleUseCase = IsCommentVisibleUseCase()

    func execute(comments: [Comment], readingProgress: ReadingProgress) -> [Comment] {
        comments.filter { comment in
            isCommentVisibleUseCase.execute(comment: comment, readingProgress: readingProgress)
        }
    }
}
