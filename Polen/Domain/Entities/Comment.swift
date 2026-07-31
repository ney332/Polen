import Foundation

struct Comment: Identifiable, Hashable, Sendable {
    let id: UUID
    var clubID: UUID
    var bookID: UUID?
    var authorID: UUID
    var authorDisplayName: String?
    var authorAvatarAssetName: String?
    var authorAvatarImageData: Data?
    var body: String
    var pageReference: Int
    var createdAt: Date

    init(
        id: UUID = UUID(),
        clubID: UUID,
        bookID: UUID? = nil,
        authorID: UUID,
        authorDisplayName: String? = nil,
        authorAvatarAssetName: String? = nil,
        authorAvatarImageData: Data? = nil,
        body: String,
        pageReference: Int,
        createdAt: Date = .now
    ) {
        self.id = id
        self.clubID = clubID
        self.bookID = bookID
        self.authorID = authorID
        self.authorDisplayName = authorDisplayName
        self.authorAvatarAssetName = authorAvatarAssetName
        self.authorAvatarImageData = authorAvatarImageData
        self.body = body
        self.pageReference = max(0, pageReference)
        self.createdAt = createdAt
    }
}
