import Foundation

struct LoadClubBookShelfUseCase: Sendable {
    private let clubRepository: BookClubRepository

    init(clubRepository: BookClubRepository) {
        self.clubRepository = clubRepository
    }

    func execute(clubID: UUID) async throws -> [ClubBookShelfItem] {
        try await clubRepository.bookShelf(forClubID: clubID)
    }
}
