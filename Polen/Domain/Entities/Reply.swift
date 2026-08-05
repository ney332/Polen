import Foundation

struct Reply: Identifiable, Hashable, Sendable {
    let id: UUID
    var commentID: UUID
    var authorID: UUID
    var authorDisplayName: String?
    var authorAvatarAssetName: String?
    var authorAvatarImageData: Data?
    var body: String
    var audioData: Data?
    var audioDuration: TimeInterval?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        commentID: UUID,
        authorID: UUID,
        authorDisplayName: String? = nil,
        authorAvatarAssetName: String? = nil,
        authorAvatarImageData: Data? = nil,
        body: String,
        audioData: Data? = nil,
        audioDuration: TimeInterval? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.commentID = commentID
        self.authorID = authorID
        self.authorDisplayName = authorDisplayName
        self.authorAvatarAssetName = authorAvatarAssetName
        self.authorAvatarImageData = authorAvatarImageData
        self.body = body
        self.audioData = audioData
        self.audioDuration = audioDuration
        self.createdAt = createdAt
    }
}
