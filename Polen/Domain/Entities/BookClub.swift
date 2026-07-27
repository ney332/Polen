import Foundation

struct BookClub: Identifiable, Hashable, Sendable {
    let id: UUID
    var name: String
    var photoAssetName: String?
    var activeBookID: UUID
    var inviteCode: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        photoAssetName: String? = nil,
        activeBookID: UUID,
        inviteCode: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.photoAssetName = photoAssetName
        self.activeBookID = activeBookID
        self.inviteCode = inviteCode
        self.createdAt = createdAt
    }
}
