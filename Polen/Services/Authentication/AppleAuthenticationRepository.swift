import Foundation

actor AppleAuthenticationRepository: AuthenticationRepository {
    private let sessionStore: AuthenticationSessionStore
    private let credentialStateProvider: AppleCredentialStateProviding

    init(
        sessionStore: AuthenticationSessionStore = KeychainAuthenticationSessionStore(),
        credentialStateProvider: AppleCredentialStateProviding = AppleCredentialStateProvider()
    ) {
        self.sessionStore = sessionStore
        self.credentialStateProvider = credentialStateProvider
    }

    func currentUser() async throws -> UserProfile? {
        guard let profile = try await sessionStore.loadUserProfile() else {
            return nil
        }

        let state = try await credentialStateProvider.credentialState(
            forUserIdentifier: profile.appleUserIdentifier
        )

        guard state == .authorized else {
            try await sessionStore.clear()
            return nil
        }

        return profile
    }

    func signInWithApple(credential: AppleIdentityCredential) async throws -> UserProfile {
        guard !credential.userIdentifier.trimmed.isEmpty else {
            throw DomainError.invalidAppleCredential
        }

        let existingProfile = try await sessionStore.loadUserProfile()
        let displayName = credential.displayName.isEmpty
            ? existingProfile?.displayName ?? credential.email?.trimmed ?? "Leitor"
            : credential.displayName
        let stableUserID = StableUserIdentifierFactory.makeID(
            from: credential.userIdentifier
        )

        let profile = UserProfile(
            id: stableUserID,
            appleUserIdentifier: credential.userIdentifier,
            displayName: displayName,
            avatarAssetName: existingProfile?.avatarAssetName,
            avatarImageData: existingProfile?.avatarImageData,
            biography: existingProfile?.biography,
            createdAt: existingProfile?.createdAt ?? .now
        )

        try await sessionStore.save(userProfile: profile)
        return profile
    }

    func signOut() async {
        try? await sessionStore.clear()
    }
}
