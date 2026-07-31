import Foundation

struct ProfileSummary: Equatable, Sendable {
    let user: UserProfile
    let settings: UserSettings
    let clubSummary: HomeClubSummary?
}

struct LoadProfileSummaryUseCase: Sendable {
    private let clubHomeRepository: ClubHomeRepository
    private let userSettingsRepository: UserSettingsRepository
    private let userProfileRepository: UserProfileRepository

    init(
        clubHomeRepository: ClubHomeRepository,
        userSettingsRepository: UserSettingsRepository,
        userProfileRepository: UserProfileRepository
    ) {
        self.clubHomeRepository = clubHomeRepository
        self.userSettingsRepository = userSettingsRepository
        self.userProfileRepository = userProfileRepository
    }

    func execute(user: UserProfile, cachedClubSummary: HomeClubSummary? = nil) async throws -> ProfileSummary {
        async let settings = userSettingsRepository.settings(for: user.id)
        async let storedUser = userProfileRepository.profile(for: user.id)

        let clubSummary: HomeClubSummary?
        if let cachedClubSummary {
            clubSummary = cachedClubSummary
        } else {
            clubSummary = try await clubHomeRepository.currentSummary(for: user.id)
        }

        return try await ProfileSummary(
            user: storedUser ?? user,
            settings: settings,
            clubSummary: clubSummary
        )
    }
}
