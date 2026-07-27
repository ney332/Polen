import Foundation

struct Membership: Identifiable, Hashable, Sendable {
    let id: UUID
    var userID: UUID
    var clubID: UUID
    var role: MembershipRole
    var joinedAt: Date

    init(
        id: UUID = UUID(),
        userID: UUID,
        clubID: UUID,
        role: MembershipRole = .member,
        joinedAt: Date = .now
    ) {
        self.id = id
        self.userID = userID
        self.clubID = clubID
        self.role = role
        self.joinedAt = joinedAt
    }
}

enum MembershipRole: String, Sendable {
    case owner
    case member
}
