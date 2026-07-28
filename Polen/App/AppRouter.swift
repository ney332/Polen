import Observation
import SwiftUI

@MainActor
@Observable
final class AppRouter {
    var path = NavigationPath()

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    func openJoinClub(inviteCode: String) {
        popToRoot()
        navigate(to: .joinClub(inviteCode))
    }
}

enum AppRoute: Hashable {
    case profile
    case createClub
    case joinClub(String?)
    case clubHome
}
