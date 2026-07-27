import AuthenticationServices
import Foundation
import Observation

@MainActor
@Observable
final class SignInViewModel {
    var isSigningIn = false
    var errorMessage: String?

    private let signInUseCase: SignInUseCase
    private let appState: AppState

    init(signInUseCase: SignInUseCase, appState: AppState) {
        self.signInUseCase = signInUseCase
        self.appState = appState
    }

    func configure(request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }

    func handleAuthorization(_ result: Result<ASAuthorization, Error>) async {
        isSigningIn = true
        errorMessage = nil

        do {
            let authorization = try result.get()
            let credential = try AppleIdentityCredentialMapper.map(from: authorization)
            let profile = try await signInUseCase.execute(credential: credential)
            appState.completeSignIn(with: profile)
        } catch {
            errorMessage = error.localizedDescription
        }

        isSigningIn = false
    }
}
