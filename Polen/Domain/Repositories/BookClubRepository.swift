import Foundation

protocol BookClubRepository: Sendable {
    func currentClub(for userID: UUID) async throws -> BookClub?
    func createClub(_ club: BookClub, book: Book?, ownerID: UUID) async throws
    func setActiveBook(_ book: Book, forClubID clubID: UUID, userID: UUID) async throws -> BookClub
    func bookShelf(forClubID clubID: UUID) async throws -> [ClubBookShelfItem]
    func joinClub(inviteCode: String, userID: UUID) async throws -> BookClub
    func leaveClub(userID: UUID) async throws
}
