import Foundation
import Observation

@MainActor
@Observable
final class ProfileViewModel {
    private(set) var summary: ProfileSummary?
    private(set) var errorMessage: String?
    var notificationsEnabled = true
    var selectedAvatarName = "person.crop.circle.fill"
    var displayNameDraft = ""
    var biographyDraft = ""
    var avatarImageData: Data?
    var clubBookSearchQuery = ""
    var clubBookSearchState: BookSearchState = .idle
    var clubBookSearchResults: [Book] = []
    var clubBookShelf: [ClubBookShelfItem] = []
    var isLoadingBookShelf = false
    var shelfCommentStates: [String: CommentTimelineState] = [:]
    var isSavingProfile = false
    var isLeavingClub = false
    var isChangingClubBook = false

    private let appState: AppState
    private let router: AppRouter
    private let loadProfileSummaryUseCase: LoadProfileSummaryUseCase
    private let saveUserSettingsUseCase: SaveUserSettingsUseCase
    private let saveUserProfileUseCase: SaveUserProfileUseCase
    private let leaveClubUseCase: LeaveClubUseCase
    private let searchGoogleBooksUseCase: SearchGoogleBooksUseCase
    private let saveSelectedBookMetadataUseCase: SaveSelectedBookMetadataUseCase
    private let setActiveBookUseCase: SetActiveBookUseCase
    private let loadClubBookShelfUseCase: LoadClubBookShelfUseCase
    private let loadBookCommentsUseCase: LoadBookCommentsUseCase

    var displayName: String {
        summary?.user.displayName ?? appState.currentUser?.displayName ?? "Leitor"
    }

    var createdAtText: String {
        guard let createdAt = summary?.user.createdAt ?? appState.currentUser?.createdAt else {
            return ""
        }

        return "Entrou em \(createdAt.formatted(date: .abbreviated, time: .omitted))"
    }

    init(
        appState: AppState,
        router: AppRouter,
        clubHomeRepository: ClubHomeRepository,
        bookRepository: BookRepository,
        userSettingsRepository: UserSettingsRepository,
        userProfileRepository: UserProfileRepository,
        clubRepository: BookClubRepository,
        commentRepository: CommentRepository
    ) {
        self.appState = appState
        self.router = router
        self.loadProfileSummaryUseCase = LoadProfileSummaryUseCase(
            clubHomeRepository: clubHomeRepository,
            userSettingsRepository: userSettingsRepository,
            userProfileRepository: userProfileRepository
        )
        self.saveUserSettingsUseCase = SaveUserSettingsUseCase(
            userSettingsRepository: userSettingsRepository
        )
        self.saveUserProfileUseCase = SaveUserProfileUseCase(
            userProfileRepository: userProfileRepository
        )
        self.leaveClubUseCase = LeaveClubUseCase(clubRepository: clubRepository)
        self.searchGoogleBooksUseCase = SearchGoogleBooksUseCase(bookRepository: bookRepository)
        self.saveSelectedBookMetadataUseCase = SaveSelectedBookMetadataUseCase(bookRepository: bookRepository)
        self.setActiveBookUseCase = SetActiveBookUseCase(clubRepository: clubRepository)
        self.loadClubBookShelfUseCase = LoadClubBookShelfUseCase(clubRepository: clubRepository)
        self.loadBookCommentsUseCase = LoadBookCommentsUseCase(commentRepository: commentRepository)
        self.notificationsEnabled = appState.settings.notificationsEnabled
        self.selectedAvatarName = appState.currentUser?.avatarAssetName ?? selectedAvatarName
        self.displayNameDraft = appState.currentUser?.displayName ?? ""
        self.biographyDraft = appState.currentUser?.biography ?? ""
        self.avatarImageData = appState.currentUser?.avatarImageData
    }

    func load() async {
        guard let user = appState.currentUser else {
            errorMessage = DomainError.unauthenticated.localizedDescription
            return
        }

        let cachedClubSummary = appState.currentClubSummary
        apply(
            ProfileSummary(
                user: user,
                settings: appState.settings,
                clubSummary: cachedClubSummary
            ),
            shouldUpdateSharedState: false
        )

        do {
            let summary = try await loadProfileSummaryUseCase.execute(
                user: user,
                cachedClubSummary: cachedClubSummary
            )
            apply(summary)
            await loadBookShelf()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func chooseAvatar(_ symbolName: String) {
        selectedAvatarName = symbolName
        appState.currentUser?.avatarAssetName = symbolName
    }

    func updateAvatarImageData(_ data: Data?) async {
        avatarImageData = data
        await saveProfile()
    }

    func saveProfile() async {
        guard var profile = appState.currentUser else {
            errorMessage = DomainError.unauthenticated.localizedDescription
            return
        }

        let trimmedName = displayNameDraft.trimmed

        guard !trimmedName.isEmpty else {
            errorMessage = "O nome não pode ficar vazio."
            return
        }

        isSavingProfile = true
        errorMessage = nil

        profile.displayName = trimmedName
        profile.biography = biographyDraft.trimmed.isEmpty ? nil : biographyDraft.trimmed
        profile.avatarAssetName = selectedAvatarName
        profile.avatarImageData = avatarImageData

        do {
            try await saveUserProfileUseCase.execute(profile: profile)
            appState.currentUser = profile
            summary = summary.map { currentSummary in
                ProfileSummary(
                    user: profile,
                    settings: currentSummary.settings,
                    clubSummary: currentSummary.clubSummary
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isSavingProfile = false
    }

    func saveNotificationPreference() async {
        guard let userID = appState.currentUser?.id else {
            return
        }

        let settings = UserSettings(notificationsEnabled: notificationsEnabled)
        appState.settings = settings
        await saveUserSettingsUseCase.execute(settings: settings, userID: userID)
    }

    func searchClubBooks() async {
        errorMessage = nil

        guard !clubBookSearchQuery.trimmed.isEmpty else {
            clubBookSearchResults = []
            clubBookSearchState = .idle
            return
        }

        clubBookSearchState = .loading

        do {
            let books = try await searchGoogleBooksUseCase.execute(query: clubBookSearchQuery)
            clubBookSearchResults = books
            clubBookSearchState = books.isEmpty ? .empty : .loaded
        } catch {
            clubBookSearchResults = []
            clubBookSearchState = .failed(error.localizedDescription)
        }
    }

    func setClubBook(_ book: Book) async {
        guard let user = appState.currentUser,
              let clubSummary = summary?.clubSummary else {
            errorMessage = DomainError.unauthenticated.localizedDescription
            return
        }

        isChangingClubBook = true
        errorMessage = nil

        do {
            try await saveSelectedBookMetadataUseCase.execute(book: book)
            _ = try await setActiveBookUseCase.execute(
                book: book,
                clubID: clubSummary.id,
                userID: user.id
            )

            let progress = ReadingProgress(userID: user.id, clubID: clubSummary.id, bookID: book.id)
            let updatedClubSummary = HomeClubSummary(
                id: clubSummary.id,
                clubName: clubSummary.clubName,
                photoAssetName: clubSummary.photoAssetName,
                inviteCode: clubSummary.inviteCode,
                activeBook: book,
                readingProgress: progress,
                memberCount: clubSummary.memberCount
            )

            appState.updateClubSummary(updatedClubSummary)

            if let currentSummary = summary {
                summary = ProfileSummary(
                    user: currentSummary.user,
                    settings: currentSummary.settings,
                    clubSummary: updatedClubSummary
                )
            }

            await loadBookShelf()
        } catch {
            errorMessage = error.localizedDescription
        }

        isChangingClubBook = false
    }

    func loadBookShelf() async {
        guard let clubID = summary?.clubSummary?.id else {
            clubBookShelf = []
            return
        }

        isLoadingBookShelf = true

        do {
            clubBookShelf = try await loadClubBookShelfUseCase.execute(clubID: clubID)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingBookShelf = false
    }

    func loadComments(for item: ClubBookShelfItem) async {
        shelfCommentStates[item.id] = .loading

        do {
            let comments = try await loadBookCommentsUseCase.execute(
                clubID: item.clubID,
                bookID: item.book.id
            )
            shelfCommentStates[item.id] = comments.isEmpty ? .empty : .loaded(comments)
        } catch {
            shelfCommentStates[item.id] = .failed(error.localizedDescription)
        }
    }

    func signOut() async {
        await saveNotificationPreference()
        await appState.signOut()
    }

    func leaveClub() async {
        guard let userID = appState.currentUser?.id else {
            errorMessage = DomainError.unauthenticated.localizedDescription
            return
        }

        isLeavingClub = true
        errorMessage = nil

        do {
            try await leaveClubUseCase.execute(userID: userID)
            appState.clearClub()
            clubBookShelf = []
            shelfCommentStates = [:]
            clubBookSearchQuery = ""
            clubBookSearchResults = []
            clubBookSearchState = .idle

            if let currentSummary = summary {
                summary = ProfileSummary(
                    user: currentSummary.user,
                    settings: currentSummary.settings,
                    clubSummary: nil
                )
            }

            isLeavingClub = false
            router.popToRoot()
            return
        } catch {
            errorMessage = error.localizedDescription
        }

        isLeavingClub = false
    }

    private func apply(_ summary: ProfileSummary, shouldUpdateSharedState: Bool = true) {
        self.summary = summary
        notificationsEnabled = summary.settings.notificationsEnabled
        selectedAvatarName = summary.user.avatarAssetName ?? selectedAvatarName
        displayNameDraft = summary.user.displayName
        biographyDraft = summary.user.biography ?? ""
        avatarImageData = summary.user.avatarImageData

        guard shouldUpdateSharedState else {
            return
        }

        appState.settings = summary.settings
        appState.currentUser = summary.user

        if let clubSummary = summary.clubSummary {
            appState.updateClubSummary(clubSummary)
        } else {
            appState.readingProgress = nil
        }
    }
}
