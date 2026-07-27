import Foundation

struct LoadClubHomeSummaryUseCase: Sendable {
    private let clubHomeRepository: ClubHomeRepository

    init(clubHomeRepository: ClubHomeRepository) {
        self.clubHomeRepository = clubHomeRepository
    }

    func execute(userID: UUID) async throws -> HomeClubSummary? {
        try await clubHomeRepository.currentSummary(for: userID)
    }

    func execute(clubID: UUID, userID: UUID) async throws -> HomeClubSummary {
        try await clubHomeRepository.summary(for: clubID, userID: userID)
    }
}
