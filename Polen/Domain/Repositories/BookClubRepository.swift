import Foundation

protocol BookClubRepository: Sendable {
    func currentClub(for userID: UUID) async throws -> BookClub?
    func createClub(_ club: BookClub, book: Book, ownerID: UUID) async throws
    func joinClub(inviteCode: String, userID: UUID) async throws -> BookClub
}
