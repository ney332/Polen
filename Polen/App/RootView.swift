import SwiftUI

struct RootView: View {
    @Bindable var appState: AppState
    @Bindable var router: AppRouter

    let dependencies: AppDependencyContainer

    var body: some View {
        NavigationStack(path: $router.path) {
            content
                .navigationDestination(for: AppRoute.self) { route in
                    destination(for: route)
                }
        }
        .tint(PollenColors.primary)
        .onChange(of: appState.sessionState) { _, newState in
            guard newState == .signedIn,
                  let inviteCode = appState.consumePendingInviteCode() else {
                return
            }

            router.openJoinClub(inviteCode: inviteCode)
        }
        .onChange(of: appState.currentClubID) { _, newClubID in
            guard appState.sessionState == .signedIn, newClubID == nil else {
                return
            }

            Task {
                await dependencies.homeViewModel.load()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch appState.sessionState {
        case .launching:
            SplashView()
                .task {
                    await appState.bootstrap()
                }
        case .signedOut:
            SignInView(
                viewModel: SignInViewModel(
                    signInUseCase: dependencies.signInUseCase,
                    appState: appState
                )
            )
        case .signedIn:
            HomeView(
                viewModel: dependencies.homeViewModel
            )
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .profile:
            ProfileView(
                viewModel: ProfileViewModel(
                    appState: appState,
                    router: router,
                    clubHomeRepository: dependencies.clubHomeRepository,
                    bookRepository: dependencies.bookRepository,
                    userSettingsRepository: dependencies.userSettingsRepository,
                    userProfileRepository: dependencies.userProfileRepository,
                    clubRepository: dependencies.clubRepository,
                    commentRepository: dependencies.commentRepository
                )
            )
        case .createClub:
            CreateClubView(
                viewModel: CreateClubViewModel(
                    appState: appState,
                    router: router,
                    bookRepository: dependencies.bookRepository,
                    clubRepository: dependencies.clubRepository
                )
            )
        case .joinClub(let inviteCode):
            JoinClubView(
                viewModel: JoinClubViewModel(
                    appState: appState,
                    router: router,
                    clubRepository: dependencies.clubRepository,
                    initialInviteCode: inviteCode
                )
            )
        case .clubHome:
            HomeView(
                viewModel: dependencies.homeViewModel
            )
        }
    }
}
