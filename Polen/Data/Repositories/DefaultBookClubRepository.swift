import Foundation

actor DefaultBookClubRepository: BookClubRepository {
    private let cloudKitStore: CloudKitBookClubStoring

    init(cloudKitStore: CloudKitBookClubStoring) {
        self.cloudKitStore = cloudKitStore
    }

    func currentClub(for userID: UUID) async throws -> BookClub? {
        try await cloudKitStore.currentClub(for: userID)
    }

    func createClub(_ club: BookClub, book: Book?, ownerID: UUID) async throws {
        try await cloudKitStore.createClub(club, book: book, ownerID: ownerID)
    }

    func setActiveBook(_ book: Book, forClubID clubID: UUID, userID: UUID) async throws -> BookClub {
        try await cloudKitStore.setActiveBook(book, forClubID: clubID, userID: userID)
    }

    func bookShelf(forClubID clubID: UUID) async throws -> [ClubBookShelfItem] {
        try await cloudKitStore.bookShelf(forClubID: clubID)
    }

    func joinClub(inviteCode: String, userID: UUID) async throws -> BookClub {
        try await cloudKitStore.joinClub(inviteCode: inviteCode, userID: userID)
    }

    func leaveClub(userID: UUID) async throws {
        try await cloudKitStore.leaveClub(userID: userID)
    }
}
