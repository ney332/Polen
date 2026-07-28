import Foundation

enum ReplyThreadState: Equatable {
    case collapsed
    case loading
    case loaded([Reply])
    case empty
    case failed(String)
}
