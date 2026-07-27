import Foundation

struct IsCommentVisibleUseCase: Sendable {
    func execute(comment: Comment, readingProgress: ReadingProgress) -> Bool {
        comment.pageReference <= readingProgress.currentPage
    }
}
