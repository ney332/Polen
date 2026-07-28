import Foundation

struct LeaveClubUseCase: Sendable {
    private let clubRepository: BookClubRepository

    init(clubRepository: BookClubRepository) {
        self.clubRepository = clubRepository
    }

    func execute(userID: UUID) async throws {
        try await clubRepository.leaveClub(userID: userID)
    }
}
