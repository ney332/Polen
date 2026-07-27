import Foundation

struct PollenNotification: Identifiable, Hashable, Sendable {
    let id: UUID
    var userID: UUID
    var title: String
    var message: String
    var createdAt: Date

    init(id: UUID = UUID(), userID: UUID, title: String, message: String, createdAt: Date = .now) {
        self.id = id
        self.userID = userID
        self.title = title
        self.message = message
        self.createdAt = createdAt
    }
}
