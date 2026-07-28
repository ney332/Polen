import Foundation

struct HomeClubSummary: Equatable, Identifiable, Sendable {
    let id: UUID
    let clubName: String
    let photoAssetName: String?
    let inviteCode: String
    let activeBook: Book
    let readingProgress: ReadingProgress
    let memberCount: Int
}
