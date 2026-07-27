import Foundation

struct ResolveHomeStateUseCase: Sendable {
    func execute(currentClubID: UUID?) -> HomeState {
        guard let currentClubID else {
            return .empty
        }

        return .club(.placeholder(id: currentClubID))
    }
}

extension HomeClubSummary {
    static func placeholder(id: UUID) -> HomeClubSummary {
        HomeClubSummary(
            id: id,
            clubName: "",
            photoAssetName: nil,
            inviteCode: "",
            activeBook: Book(googleBooksID: "", title: ""),
            readingProgress: ReadingProgress(userID: UUID(), clubID: id, bookID: UUID()),
            memberCount: 0
        )
    }
}
