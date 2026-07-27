import Foundation

struct CreateClubUseCase: Sendable {
    private let clubRepository: BookClubRepository

    init(clubRepository: BookClubRepository) {
        self.clubRepository = clubRepository
    }

    func execute(draft: CreateClubDraft, ownerID: UUID) async throws -> BookClub {
        let name = draft.name.trimmed

        guard !name.isEmpty else {
            throw ClubFlowError.missingClubName
        }

        guard let selectedBook = draft.selectedBook else {
            throw ClubFlowError.missingBook
        }

        let club = BookClub(
            name: name,
            photoAssetName: draft.photoSymbolName,
            activeBookID: selectedBook.id,
            inviteCode: InviteCodeGenerator.makeCode(from: name)
        )

        try await clubRepository.createClub(club, book: selectedBook, ownerID: ownerID)

        return club
    }
}
