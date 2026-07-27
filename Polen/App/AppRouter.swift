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
}

enum AppRoute: Hashable {
    case profile
    case createClub
    case joinClub
    case clubHome
}
