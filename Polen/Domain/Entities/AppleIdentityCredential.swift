import Foundation

struct AppleIdentityCredential: Hashable, Sendable {
    let userIdentifier: String
    let givenName: String?
    let familyName: String?
    let email: String?

    var displayName: String {
        [givenName, familyName]
            .compactMap { $0?.trimmed }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
