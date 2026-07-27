import AuthenticationServices
import Foundation

enum AppleIdentityCredentialMapper {
    static func map(from authorization: ASAuthorization) throws -> AppleIdentityCredential {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw DomainError.invalidAppleCredential
        }

        return AppleIdentityCredential(
            userIdentifier: credential.user,
            givenName: credential.fullName?.givenName,
            familyName: credential.fullName?.familyName,
            email: credential.email
        )
    }
}
