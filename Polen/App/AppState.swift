import Foundation
import Observation

@MainActor
@Observable
final class AppState {
    var sessionState: SessionState = .launching
    var currentUser: UserProfile?
    var currentClubID: UUID?
    var readingProgress: ReadingProgress?
    var settings: UserSettings = .default

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

    func enterClub(id clubID: UUID) {
        currentClubID = clubID
    }

    func signOut() async {
        await authenticationRepository.signOut()
        currentUser = nil
        currentClubID = nil
        readingProgress = nil
        sessionState = .signedOut
    }
}

enum SessionState: Equatable {
    case launching
    case signedOut
    case signedIn
}
