import Foundation

protocol AuthenticationSessionStore: Sendable {
    func loadUserProfile() async throws -> UserProfile?
    func save(userProfile: UserProfile) async throws
    func clear() async throws
}
