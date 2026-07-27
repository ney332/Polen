import Foundation

struct UserProfile: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var appleUserIdentifier: String
    var displayName: String
    var avatarAssetName: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        appleUserIdentifier: String,
        displayName: String,
        avatarAssetName: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.appleUserIdentifier = appleUserIdentifier
        self.displayName = displayName
        self.avatarAssetName = avatarAssetName
        self.createdAt = createdAt
    }
}
