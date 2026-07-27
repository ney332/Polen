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
                viewModel: HomeViewModel(
                    appState: appState,
                    router: router,
                    clubHomeRepository: dependencies.clubHomeRepository,
                    readingProgressRepository: dependencies.readingProgressRepository,
                    commentRepository: dependencies.commentRepository
                )
            )
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .profile:
            ProfileView(viewModel: ProfileViewModel(appState: appState))
        case .createClub:
            CreateClubView(
                viewModel: CreateClubViewModel(
                    appState: appState,
                    router: router,
                    bookRepository: dependencies.bookRepository,
                    clubRepository: dependencies.clubRepository
                )
            )
        case .joinClub:
            JoinClubView(
                viewModel: JoinClubViewModel(
                    appState: appState,
                    router: router,
                    clubRepository: dependencies.clubRepository
                )
            )
        case .clubHome:
            HomeView(
                viewModel: HomeViewModel(
                    appState: appState,
                    router: router,
                    clubHomeRepository: dependencies.clubHomeRepository,
                    readingProgressRepository: dependencies.readingProgressRepository,
                    commentRepository: dependencies.commentRepository
                )
            )
        }
    }
}
