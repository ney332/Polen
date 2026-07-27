import Foundation

enum CommentTimelineState: Equatable {
    case loading
    case loaded([Comment])
    case empty
    case failed(String)
}
