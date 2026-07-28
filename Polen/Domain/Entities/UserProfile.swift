import Foundation

struct UserProfile: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var appleUserIdentifier: String
    var displayName: String
    var avatarAssetName: String?
    var avatarImageData: Data?
    var biography: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        appleUserIdentifier: String,
        displayName: String,
        avatarAssetName: String? = nil,
        avatarImageData: Data? = nil,
        biography: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.appleUserIdentifier = appleUserIdentifier
        self.displayName = displayName
        self.avatarAssetName = avatarAssetName
        self.avatarImageData = avatarImageData
        self.biography = biography
        self.createdAt = createdAt
    }
}
