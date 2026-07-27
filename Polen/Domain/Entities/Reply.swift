import Foundation

struct Reply: Identifiable, Hashable, Sendable {
    let id: UUID
    var commentID: UUID
    var authorID: UUID
    var body: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        commentID: UUID,
        authorID: UUID,
        body: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.commentID = commentID
        self.authorID = authorID
        self.body = body
        self.createdAt = createdAt
    }
}
