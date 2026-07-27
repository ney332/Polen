import Foundation

struct Comment: Identifiable, Hashable, Sendable {
    let id: UUID
    var clubID: UUID
    var authorID: UUID
    var body: String
    var pageReference: Int
    var createdAt: Date

    init(
        id: UUID = UUID(),
        clubID: UUID,
        authorID: UUID,
        body: String,
        pageReference: Int,
        createdAt: Date = .now
    ) {
        self.id = id
        self.clubID = clubID
        self.authorID = authorID
        self.body = body
        self.pageReference = max(0, pageReference)
        self.createdAt = createdAt
    }
}
