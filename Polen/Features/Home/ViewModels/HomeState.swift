import Foundation

enum HomeState: Equatable {
    case loading
    case empty
    case club(HomeClubSummary)
    case failed(String)
}
