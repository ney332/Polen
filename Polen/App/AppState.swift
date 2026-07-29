import Foundation
import Observation
//
@MainActor
@Observable
final class AppState {
    var sessionState: SessionState = .launching
    var currentUser: UserProfile?
    var currentClubID: UUID?
    var currentClubSummary: HomeClubSummary?
    var readingProgress: ReadingProgress?
    var settings: UserSettings = .default
    var pendingInviteCode: String?

    private let authenticationRepository: AuthenticationRepository

    init(authenticationRepository: AuthenticationRepository) {
        self.authenticationRepository = authenticationRepository
    }

    func bootstrap() async {
        do {
            currentUser = try await authenticationRepository.currentUser()
            sessionState = currentUser == nil ? .signedOut : .signedIn
        } catch {
            sessionState = .signedOut
        }
    }

    func completeSignIn(with profile: UserProfile) {
        currentUser = profile
        sessionState = .signedIn
    }

    func storePendingInviteCode(_ inviteCode: String) {
        pendingInviteCode = inviteCode
    }

    func consumePendingInviteCode() -> String? {
        defer {
            pendingInviteCode = nil
        }

        return pendingInviteCode
    }

    func enterClub(id clubID: UUID) {
        if currentClubID != clubID {
            currentClubSummary = nil
        }

        currentClubID = clubID
    }

    func updateClubSummary(_ summary: HomeClubSummary) {
        currentClubID = summary.id
        currentClubSummary = summary
        readingProgress = summary.readingProgress
    }

    func clearClub() {
        currentClubID = nil
        currentClubSummary = nil
        readingProgress = nil
    }

    func signOut() async {
        await authenticationRepository.signOut()
        currentUser = nil
        clearClub()
        sessionState = .signedOut
    }
}

enum SessionState: Equatable {
    case launching
    case signedOut
    case signedIn
}
