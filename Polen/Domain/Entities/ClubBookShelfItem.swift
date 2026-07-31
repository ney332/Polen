import Foundation

struct ClubBookShelfItem: Identifiable, Hashable, Sendable {
    let id: String
    let clubID: UUID
    let book: Book
    let startedAt: Date
    let isActive: Bool

    init(
        id: String? = nil,
        clubID: UUID,
        book: Book,
        startedAt: Date = .now,
        isActive: Bool = false
    ) {
        self.id = id ?? "\(clubID.uuidString)-\(book.id.uuidString)"
        self.clubID = clubID
        self.book = book
        self.startedAt = startedAt
        self.isActive = isActive
    }
}
