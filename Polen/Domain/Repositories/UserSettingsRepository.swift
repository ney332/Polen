import Foundation

protocol UserSettingsRepository: Sendable {
    func settings(for userID: UUID) async -> UserSettings
    func save(_ settings: UserSettings, for userID: UUID) async
}
