import Foundation

protocol ClubHomeRepository: Sendable {
    func currentSummary(for userID: UUID) async throws -> HomeClubSummary?
    func summary(for clubID: UUID, userID: UUID) async throws -> HomeClubSummary
}
