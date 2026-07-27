import Foundation

struct SignInUseCase: Sendable {
    private let authenticationRepository: AuthenticationRepository

    init(authenticationRepository: AuthenticationRepository) {
        self.authenticationRepository = authenticationRepository
    }

    func execute(credential: AppleIdentityCredential) async throws -> UserProfile {
        try await authenticationRepository.signInWithApple(credential: credential)
    }
}
