import Foundation

protocol UserProfileRepository: Sendable {
    func profile(for userID: UUID) async throws -> UserProfile?
    func save(_ profile: UserProfile) async throws
}
