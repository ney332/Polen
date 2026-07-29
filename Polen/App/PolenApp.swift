import SwiftData
import SwiftUI

@main
struct PolenApp: App {
    private let dependencies: AppDependencyContainer
    private let modelContainer: ModelContainer

    init() {
        let dependencies = AppDependencyContainer.live()
        self.dependencies = dependencies
        self.modelContainer = dependencies.swiftDataContainer.modelContainer
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                appState: dependencies.appState,
                router: dependencies.router,
                dependencies: dependencies
            )
            .onOpenURL { url in
                guard let inviteCode = InviteLinkParser.inviteCode(from: url) else {
                    return
                }

                dependencies.appState.storePendingInviteCode(inviteCode)

                if dependencies.appState.sessionState == .signedIn {
                    _ = dependencies.appState.consumePendingInviteCode()
                    dependencies.router.openJoinClub(inviteCode: inviteCode)
                }
            }
        }
        .modelContainer(modelContainer)
    }
}
