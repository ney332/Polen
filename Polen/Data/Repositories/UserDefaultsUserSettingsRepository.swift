import Foundation

actor UserDefaultsUserSettingsRepository: UserSettingsRepository {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func settings(for userID: UUID) async -> UserSettings {
        let key = key(for: userID)

        guard userDefaults.object(forKey: key) != nil else {
            return .default
        }

        return UserSettings(
            notificationsEnabled: userDefaults.bool(forKey: key)
        )
    }

    func save(_ settings: UserSettings, for userID: UUID) async {
        userDefaults.set(settings.notificationsEnabled, forKey: key(for: userID))
    }

    private func key(for userID: UUID) -> String {
        "user-settings-\(userID.uuidString)-notifications-enabled"
    }
}
