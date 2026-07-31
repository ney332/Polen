import Foundation

struct SetActiveBookUseCase: Sendable {
    private let clubRepository: BookClubRepository

    init(clubRepository: BookClubRepository) {
        self.clubRepository = clubRepository
    }

    func execute(book: Book, clubID: UUID, userID: UUID) async throws -> BookClub {
        try await clubRepository.setActiveBook(book, forClubID: clubID, userID: userID)
    }
}
