import Foundation
import Observation

@MainActor
@Observable
final class JoinClubViewModel {
    var inviteCode = ""
    var errorMessage: String?
    var isJoining = false

    private let appState: AppState
    private let router: AppRouter
    private let joinClubUseCase: JoinClubUseCase

    init(
        appState: AppState,
        router: AppRouter,
        clubRepository: BookClubRepository
    ) {
        self.appState = appState
        self.router = router
        self.joinClubUseCase = JoinClubUseCase(clubRepository: clubRepository)
    }

    func joinClub() {
        errorMessage = nil

        guard !isJoining else {
            return
        }

        guard let userID = appState.currentUser?.id else {
            errorMessage = ClubFlowError.missingAuthenticatedUser.localizedDescription
            return
        }

        isJoining = true

        Task {
            defer {
                isJoining = false
            }

            do {
                let clubID = try await joinClubUseCase.execute(inviteCode: inviteCode, userID: userID)
                appState.enterClub(id: clubID)
                router.popToRoot()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
