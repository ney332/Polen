import Foundation

struct SaveUserSettingsUseCase: Sendable {
    private let userSettingsRepository: UserSettingsRepository

    init(userSettingsRepository: UserSettingsRepository) {
        self.userSettingsRepository = userSettingsRepository
    }

    func execute(settings: UserSettings, userID: UUID) async {
        await userSettingsRepository.save(settings, for: userID)
    }
}
