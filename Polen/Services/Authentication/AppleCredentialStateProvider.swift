import AuthenticationServices
import Foundation

protocol AppleCredentialStateProviding: Sendable {
    func credentialState(forUserIdentifier userIdentifier: String) async throws -> AppleCredentialState
}

enum AppleCredentialState: Sendable {
    case authorized
    case revoked
    case notFound
    case transferred
}

struct AppleCredentialStateProvider: AppleCredentialStateProviding {
    func credentialState(forUserIdentifier userIdentifier: String) async throws -> AppleCredentialState {
        try await withCheckedThrowingContinuation { continuation in
            ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userIdentifier) { state, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: AppleCredentialState(state))
            }
        }
    }
}

private extension AppleCredentialState {
    init(_ state: ASAuthorizationAppleIDProvider.CredentialState) {
        switch state {
        case .authorized:
            self = .authorized
        case .revoked:
            self = .revoked
        case .notFound:
            self = .notFound
        case .transferred:
            self = .transferred
        @unknown default:
            self = .notFound
        }
    }
}
