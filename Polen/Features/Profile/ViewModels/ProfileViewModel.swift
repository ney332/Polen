import Foundation
import Observation

@MainActor
@Observable
final class ProfileViewModel {
    var notificationsEnabled: Bool

    private let appState: AppState

    var displayName: String {
        appState.currentUser?.displayName ?? "Leitor"
    }

    init(appState: AppState) {
        self.appState = appState
        self.notificationsEnabled = appState.settings.notificationsEnabled
    }

    func signOut() async {
        appState.settings.notificationsEnabled = notificationsEnabled
        await appState.signOut()
    }
}
