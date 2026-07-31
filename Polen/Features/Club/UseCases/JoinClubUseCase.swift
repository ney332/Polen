import Foundation

struct JoinClubUseCase: Sendable {
    private let clubRepository: BookClubRepository

    init(clubRepository: BookClubRepository) {
        self.clubRepository = clubRepository
    }

    func execute(inviteCode: String, userID: UUID) async throws -> UUID {
        let code = inviteCode.extractedInviteCode
        let normalizedCode = code
            .uppercased()
            .filter { $0.isLetter || $0.isNumber }

        guard normalizedCode.count >= 4 else {
            throw ClubFlowError.invalidInviteCode
        }

        let club = try await clubRepository.joinClub(inviteCode: normalizedCode, userID: userID)

        return club.id
    }
}

private extension String {
    var extractedInviteCode: String {
        let trimmedInput = trimmed

        if let url = URL(string: trimmedInput),
           let code = InviteLinkParser.inviteCode(from: url) {
            return code
        }

        if let codeRange = trimmedInput.range(
            of: #"[A-Za-z0-9]{1,12}-?[0-9]{4}"#,
            options: .regularExpression
        ) {
            return String(trimmedInput[codeRange])
        }

        return trimmedInput
    }
}
