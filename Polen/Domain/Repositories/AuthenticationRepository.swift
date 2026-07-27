import Foundation

protocol AuthenticationRepository: Sendable {
    func currentUser() async throws -> UserProfile?
    func signInWithApple(credential: AppleIdentityCredential) async throws -> UserProfile
    func signOut() async
}
