import Foundation

actor DefaultUserProfileRepository: UserProfileRepository {
    private let cloudKitStore: CloudKitUserProfileStoring
    private let sessionStore: AuthenticationSessionStore

    init(
        cloudKitStore: CloudKitUserProfileStoring,
        sessionStore: AuthenticationSessionStore = KeychainAuthenticationSessionStore()
    ) {
        self.cloudKitStore = cloudKitStore
        self.sessionStore = sessionStore
    }

    func profile(for userID: UUID) async throws -> UserProfile? {
        guard let profile = try await cloudKitStore.profile(for: userID) else {
            return nil
        }

        try await sessionStore.save(userProfile: profile)
        return profile
    }

    func save(_ profile: UserProfile) async throws {
        try await cloudKitStore.save(profile)
        try await sessionStore.save(userProfile: profile)
    }
}
