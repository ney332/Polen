import Foundation

struct JoinClubUseCase: Sendable {
    private let clubRepository: BookClubRepository

    init(clubRepository: BookClubRepository) {
        self.clubRepository = clubRepository
    }

    func execute(inviteCode: String, userID: UUID) async throws -> UUID {
        let normalizedCode = inviteCode
            .trimmed
            .uppercased()
            .filter { $0.isLetter || $0.isNumber }

        guard normalizedCode.count >= 4 else {
            throw ClubFlowError.invalidInviteCode
        }

        let club = try await clubRepository.joinClub(inviteCode: normalizedCode, userID: userID)

        return club.id
    }
}
