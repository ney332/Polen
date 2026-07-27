import Foundation

struct ReadingProgress: Identifiable, Hashable, Sendable {
    let id: UUID
    var userID: UUID
    var clubID: UUID
    var bookID: UUID
    var currentPage: Int
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        userID: UUID,
        clubID: UUID,
        bookID: UUID,
        currentPage: Int = 0,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.userID = userID
        self.clubID = clubID
        self.bookID = bookID
        self.currentPage = max(0, currentPage)
        self.updatedAt = updatedAt
    }
}
