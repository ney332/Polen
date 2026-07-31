import CloudKit

enum CloudKitRecordType {
    static let userProfile = "UserProfile"
    static let book = "Book"
    static let bookClub = "BookClub"
    static let membership = "Membership"
    static let readingProgress = "ReadingProgress"
    static let comment = "Comment"
    static let reply = "Reply"
}

enum CloudKitField {
    enum Shared {
        static let id = "id"
    }

    enum UserProfile {
        static let appleUserIdentifier = "appleUserIdentifier"
        static let displayName = "displayName"
        static let avatarAssetName = "avatarAssetName"
        static let avatarImage = "avatarImage"
        static let biography = "biography"
        static let createdAt = "createdAt"
    }

    enum Book {
        static let googleBooksID = "googleBooksID"
        static let title = "title"
        static let authors = "authors"
        static let isbn = "isbn"
        static let description = "description"
        static let pageCount = "pageCount"
        static let coverURL = "coverURL"
    }

    enum BookClub {
        static let name = "name"
        static let photoAssetName = "photoAssetName"
        static let activeBookID = "activeBookID"
        static let inviteCode = "inviteCode"
        static let createdAt = "createdAt"
    }

    enum Membership {
        static let userID = "userID"
        static let clubID = "clubID"
        static let role = "role"
        static let joinedAt = "joinedAt"
    }

    enum ReadingProgress {
        static let userID = "userID"
        static let clubID = "clubID"
        static let bookID = "bookID"
        static let currentPage = "currentPage"
        static let updatedAt = "updatedAt"
    }

    enum Comment {
        static let clubID = "clubID"
        static let authorID = "authorID"
        static let authorDisplayName = "authorDisplayName"
        static let authorAvatarAssetName = "authorAvatarAssetName"
        static let authorAvatarImage = "authorAvatarImage"
        static let body = "body"
        static let pageReference = "pageReference"
        static let createdAt = "createdAt"
    }

    enum Reply {
        static let commentID = "commentID"
        static let authorID = "authorID"
        static let authorDisplayName = "authorDisplayName"
        static let authorAvatarAssetName = "authorAvatarAssetName"
        static let authorAvatarImage = "authorAvatarImage"
        static let body = "body"
        static let createdAt = "createdAt"
    }
}

enum CloudKitRecordMappingError: Error {
    case missingField(String)
    case invalidField(String)
}

extension CKRecord.ID {
    convenience init(recordName uuid: UUID) {
        self.init(recordName: uuid.uuidString)
    }
}
