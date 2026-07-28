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
    var isSavingProfile = false
    var isLeavingClub = false

    private let appState: AppState
    private let loadProfileSummaryUseCase: LoadProfileSummaryUseCase
    private let saveUserSettingsUseCase: SaveUserSettingsUseCase
    private let saveUserProfileUseCase: SaveUserProfileUseCase
    private let leaveClubUseCase: LeaveClubUseCase
    let clubInviteShareStore: CloudKitClubInviteShareStore

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
        clubHomeRepository: ClubHomeRepository,
        userSettingsRepository: UserSettingsRepository,
        userProfileRepository: UserProfileRepository,
        clubRepository: BookClubRepository,
        clubInviteShareStore: CloudKitClubInviteShareStore
    ) {
        self.appState = appState
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
        self.clubInviteShareStore = clubInviteShareStore
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

        do {
            let summary = try await loadProfileSummaryUseCase.execute(user: user)
            self.summary = summary
            notificationsEnabled = summary.settings.notificationsEnabled
            selectedAvatarName = summary.user.avatarAssetName ?? selectedAvatarName
            displayNameDraft = summary.user.displayName
            biographyDraft = summary.user.biography ?? ""
            avatarImageData = summary.user.avatarImageData
            appState.settings = summary.settings
            appState.currentUser = summary.user
            appState.readingProgress = summary.clubSummary?.readingProgress

            if let clubSummary = summary.clubSummary {
                appState.updateClubSummary(clubSummary)
            }
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

            if let currentSummary = summary {
                summary = ProfileSummary(
                    user: currentSummary.user,
                    settings: currentSummary.settings,
                    clubSummary: nil
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLeavingClub = false
    }
}
