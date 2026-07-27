import Foundation

protocol NotificationService: Sendable {
    func registerForRemoteNotifications() async throws
}

struct APNSNotificationService: NotificationService {
    func registerForRemoteNotifications() async throws {
    }
}
