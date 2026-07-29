import Foundation

@MainActor
struct AppDependencyContainer {
    let appState: AppState
    let router: AppRouter
    let swiftDataContainer: SwiftDataContainer
    let cloudKitContainerProvider: CloudKitContainerProviding
    let authenticationRepository: AuthenticationRepository
    let bookRepository: BookRepository
    let clubRepository: BookClubRepository
    let clubHomeRepository: ClubHomeRepository
    let readingProgressRepository: ReadingProgressRepository
    let commentRepository: CommentRepository
    let userSettingsRepository: UserSettingsRepository
    let userProfileRepository: UserProfileRepository
    let signInUseCase: SignInUseCase
    let homeViewModel: HomeViewModel

    static func live() -> AppDependencyContainer {
        let swiftDataContainer = SwiftDataContainer.makeLive()
        let cloudKitProvider = DefaultCloudKitContainerProvider(configuration: .production)
        let authenticationRepository = AppleAuthenticationRepository()
        let bookRepository = DefaultBookRepository()
        let clubHomeStore = CloudKitClubHomeStore(containerProvider: cloudKitProvider)
        let clubRepository = DefaultBookClubRepository(
            cloudKitStore: CloudKitBookClubStore(containerProvider: cloudKitProvider)
        )
        let clubHomeRepository = DefaultClubHomeRepository(
            cloudKitStore: clubHomeStore
        )
        let readingProgressRepository = DefaultReadingProgressRepository(
            cloudKitStore: clubHomeStore
        )
        let commentRepository = DefaultCommentRepository(
            cloudKitStore: CloudKitCommentStore(containerProvider: cloudKitProvider)
        )
        let userSettingsRepository = UserDefaultsUserSettingsRepository()
        let userProfileRepository = DefaultUserProfileRepository(
            cloudKitStore: CloudKitUserProfileStore(containerProvider: cloudKitProvider)
        )
        let appState = AppState(authenticationRepository: authenticationRepository)
        let router = AppRouter()
        let homeViewModel = HomeViewModel(
            appState: appState,
            router: router,
            clubHomeRepository: clubHomeRepository,
            readingProgressRepository: readingProgressRepository,
            commentRepository: commentRepository
        )

        return AppDependencyContainer(
            appState: appState,
            router: router,
            swiftDataContainer: swiftDataContainer,
            cloudKitContainerProvider: cloudKitProvider,
            authenticationRepository: authenticationRepository,
            bookRepository: bookRepository,
            clubRepository: clubRepository,
            clubHomeRepository: clubHomeRepository,
            readingProgressRepository: readingProgressRepository,
            commentRepository: commentRepository,
            userSettingsRepository: userSettingsRepository,
            userProfileRepository: userProfileRepository,
            signInUseCase: SignInUseCase(authenticationRepository: authenticationRepository),
            homeViewModel: homeViewModel
        )
    }
}
