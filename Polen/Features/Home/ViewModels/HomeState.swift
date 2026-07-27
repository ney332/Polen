import Foundation

enum HomeState: Equatable {
    case loading
    case empty
    case club(HomeClubSummary)
    case failed(String)
}

struct HomeClubSummary: Equatable, Identifiable {
    let id: UUID
    let clubName: String
    let photoAssetName: String?
    let inviteCode: String
    let activeBook: Book
    let readingProgress: ReadingProgress
    let memberCount: Int
}
