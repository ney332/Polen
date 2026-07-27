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
    let signInUseCase: SignInUseCase

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
        let appState = AppState(authenticationRepository: authenticationRepository)

        return AppDependencyContainer(
            appState: appState,
            router: AppRouter(),
            swiftDataContainer: swiftDataContainer,
            cloudKitContainerProvider: cloudKitProvider,
            authenticationRepository: authenticationRepository,
            bookRepository: bookRepository,
            clubRepository: clubRepository,
            clubHomeRepository: clubHomeRepository,
            readingProgressRepository: readingProgressRepository,
            commentRepository: commentRepository,
            signInUseCase: SignInUseCase(authenticationRepository: authenticationRepository)
        )
    }
}
