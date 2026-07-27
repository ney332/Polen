import Foundation
import SwiftData

@Model
final class StoredUserProfile {
    @Attribute(.unique) var id: UUID
    var appleUserIdentifier: String
    var displayName: String
    var avatarAssetName: String?
    var createdAt: Date

    init(id: UUID, appleUserIdentifier: String, displayName: String, avatarAssetName: String?, createdAt: Date) {
        self.id = id
        self.appleUserIdentifier = appleUserIdentifier
        self.displayName = displayName
        self.avatarAssetName = avatarAssetName
        self.createdAt = createdAt
    }
}

@Model
final class StoredReadingProgress {
    @Attribute(.unique) var id: UUID
    var userID: UUID
    var clubID: UUID
    var bookID: UUID
    var currentPage: Int
    var updatedAt: Date

    init(id: UUID, userID: UUID, clubID: UUID, bookID: UUID, currentPage: Int, updatedAt: Date) {
        self.id = id
        self.userID = userID
        self.clubID = clubID
        self.bookID = bookID
        self.currentPage = currentPage
        self.updatedAt = updatedAt
    }
}

@Model
final class StoredUserSettings {
    @Attribute(.unique) var userID: UUID
    var notificationsEnabled: Bool

    init(userID: UUID, notificationsEnabled: Bool) {
        self.userID = userID
        self.notificationsEnabled = notificationsEnabled
    }
}

@Model
final class StoredBook {
    @Attribute(.unique) var id: UUID
    var googleBooksID: String
    var title: String
    var authors: [String]
    var isbn: String?
    var bookDescription: String?
    var pageCount: Int?
    var coverURL: URL?

    init(
        id: UUID,
        googleBooksID: String,
        title: String,
        authors: [String],
        isbn: String?,
        bookDescription: String?,
        pageCount: Int?,
        coverURL: URL?
    ) {
        self.id = id
        self.googleBooksID = googleBooksID
        self.title = title
        self.authors = authors
        self.isbn = isbn
        self.bookDescription = bookDescription
        self.pageCount = pageCount
        self.coverURL = coverURL
    }
}

@Model
final class StoredBookClub {
    @Attribute(.unique) var id: UUID
    var name: String
    var photoAssetName: String?
    var activeBookID: UUID
    var inviteCode: String
    var createdAt: Date

    init(id: UUID, name: String, photoAssetName: String?, activeBookID: UUID, inviteCode: String, createdAt: Date) {
        self.id = id
        self.name = name
        self.photoAssetName = photoAssetName
        self.activeBookID = activeBookID
        self.inviteCode = inviteCode
        self.createdAt = createdAt
    }
}

@Model
final class StoredMembership {
    @Attribute(.unique) var id: UUID
    var userID: UUID
    var clubID: UUID
    var role: String
    var joinedAt: Date

    init(id: UUID, userID: UUID, clubID: UUID, role: String, joinedAt: Date) {
        self.id = id
        self.userID = userID
        self.clubID = clubID
        self.role = role
        self.joinedAt = joinedAt
    }
}

@Model
final class StoredComment {
    @Attribute(.unique) var id: UUID
    var clubID: UUID
    var authorID: UUID
    var body: String
    var pageReference: Int
    var createdAt: Date

    init(id: UUID, clubID: UUID, authorID: UUID, body: String, pageReference: Int, createdAt: Date) {
        self.id = id
        self.clubID = clubID
        self.authorID = authorID
        self.body = body
        self.pageReference = pageReference
        self.createdAt = createdAt
    }
}

@Model
final class StoredReply {
    @Attribute(.unique) var id: UUID
    var commentID: UUID
    var authorID: UUID
    var body: String
    var createdAt: Date

    init(id: UUID, commentID: UUID, authorID: UUID, body: String, createdAt: Date) {
        self.id = id
        self.commentID = commentID
        self.authorID = authorID
        self.body = body
        self.createdAt = createdAt
    }
}

@Model
final class StoredPollenNotification {
    @Attribute(.unique) var id: UUID
    var userID: UUID
    var title: String
    var message: String
    var createdAt: Date

    init(id: UUID, userID: UUID, title: String, message: String, createdAt: Date) {
        self.id = id
        self.userID = userID
        self.title = title
        self.message = message
        self.createdAt = createdAt
    }
}
