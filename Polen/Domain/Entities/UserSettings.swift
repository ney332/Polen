import Foundation

struct UserSettings: Hashable, Sendable {
    var notificationsEnabled: Bool

    static let `default` = UserSettings(notificationsEnabled: true)
}
