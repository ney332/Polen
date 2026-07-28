import CloudKit
import SwiftData
import SwiftUI

@main
struct PolenApp: App {
    @UIApplicationDelegateAdaptor(PollenAppDelegate.self) private var appDelegate

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
            .onAppear {
                appDelegate.shareAcceptanceHandler = { metadata in
                    Task {
                        await handleAcceptedShare(metadata)
                    }
                }
            }
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

    private func handleAcceptedShare(_ metadata: CKShare.Metadata) async {
        do {
            let inviteCode = try await dependencies.clubInviteShareStore.acceptShare(metadata: metadata)
            dependencies.appState.storePendingInviteCode(inviteCode)

            if dependencies.appState.sessionState == .signedIn {
                _ = dependencies.appState.consumePendingInviteCode()
                dependencies.router.openJoinClub(inviteCode: inviteCode)
            }
        } catch {
            dependencies.appState.storeShareInviteError(error.localizedDescription)
        }
    }
}
