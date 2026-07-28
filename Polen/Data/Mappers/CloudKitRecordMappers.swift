import CloudKit
import Foundation

extension CKRecord {
    convenience init(book: Book) {
        self.init(recordType: CloudKitRecordType.book, recordID: CKRecord.ID(recordName: book.id))
        update(with: book)
    }

    convenience init(bookClub: BookClub) {
        self.init(recordType: CloudKitRecordType.bookClub, recordID: CKRecord.ID(recordName: bookClub.id))
        update(with: bookClub)
    }

    convenience init(membership: Membership) {
        self.init(recordType: CloudKitRecordType.membership, recordID: CKRecord.ID(recordName: membership.id))
        update(with: membership)
    }

    convenience init(readingProgress: ReadingProgress) {
        self.init(recordType: CloudKitRecordType.readingProgress, recordID: CKRecord.ID(recordName: readingProgress.id))
        update(with: readingProgress)
    }

    convenience init(comment: Comment) {
        self.init(recordType: CloudKitRecordType.comment, recordID: CKRecord.ID(recordName: comment.id))
        update(with: comment)
    }

    convenience init(reply: Reply) {
        self.init(recordType: CloudKitRecordType.reply, recordID: CKRecord.ID(recordName: reply.id))
        update(with: reply)
    }

    func update(with book: Book) {
        self[CloudKitField.Shared.id] = book.id.uuidString
        self[CloudKitField.Book.googleBooksID] = book.googleBooksID
        self[CloudKitField.Book.title] = book.title
        self[CloudKitField.Book.authors] = book.authors
        self[CloudKitField.Book.isbn] = book.isbn
        self[CloudKitField.Book.description] = book.description
        self[CloudKitField.Book.pageCount] = book.pageCount
        self[CloudKitField.Book.coverURL] = book.coverURL?.absoluteString
    }

    func update(with club: BookClub) {
        self[CloudKitField.Shared.id] = club.id.uuidString
        self[CloudKitField.BookClub.name] = club.name
        self[CloudKitField.BookClub.photoAssetName] = club.photoAssetName
        self[CloudKitField.BookClub.activeBookID] = club.activeBookID.uuidString
        self[CloudKitField.BookClub.inviteCode] = club.inviteCode
        self[CloudKitField.BookClub.createdAt] = club.createdAt
    }

    func update(with membership: Membership) {
        self[CloudKitField.Shared.id] = membership.id.uuidString
        self[CloudKitField.Membership.userID] = membership.userID.uuidString
        self[CloudKitField.Membership.clubID] = membership.clubID.uuidString
        self[CloudKitField.Membership.role] = membership.role.rawValue
        self[CloudKitField.Membership.joinedAt] = membership.joinedAt
    }

    func update(with progress: ReadingProgress) {
        self[CloudKitField.Shared.id] = progress.id.uuidString
        self[CloudKitField.ReadingProgress.userID] = progress.userID.uuidString
        self[CloudKitField.ReadingProgress.clubID] = progress.clubID.uuidString
        self[CloudKitField.ReadingProgress.bookID] = progress.bookID.uuidString
        self[CloudKitField.ReadingProgress.currentPage] = progress.currentPage
        self[CloudKitField.ReadingProgress.updatedAt] = progress.updatedAt
    }

    func update(with comment: Comment) {
        self[CloudKitField.Shared.id] = comment.id.uuidString
        self[CloudKitField.Comment.clubID] = comment.clubID.uuidString
        self[CloudKitField.Comment.authorID] = comment.authorID.uuidString
        self[CloudKitField.Comment.body] = comment.body
        self[CloudKitField.Comment.pageReference] = comment.pageReference
        self[CloudKitField.Comment.createdAt] = comment.createdAt
    }

    func update(with reply: Reply) {
        self[CloudKitField.Shared.id] = reply.id.uuidString
        self[CloudKitField.Reply.commentID] = reply.commentID.uuidString
        self[CloudKitField.Reply.authorID] = reply.authorID.uuidString
        self[CloudKitField.Reply.body] = reply.body
        self[CloudKitField.Reply.createdAt] = reply.createdAt
    }
}

extension Book {
    init(record: CKRecord) throws {
        let id = try record.uuid(for: CloudKitField.Shared.id)
        let googleBooksID = try record.string(for: CloudKitField.Book.googleBooksID)
        let title = try record.string(for: CloudKitField.Book.title)
        let coverURLString = record.optionalString(for: CloudKitField.Book.coverURL)

        self.init(
            id: id,
            googleBooksID: googleBooksID,
            title: title,
            authors: record[CloudKitField.Book.authors] as? [String] ?? [],
            isbn: record.optionalString(for: CloudKitField.Book.isbn),
            description: record.optionalString(for: CloudKitField.Book.description),
            pageCount: record[CloudKitField.Book.pageCount] as? Int,
            coverURL: coverURLString.flatMap(URL.init(string:))
        )
    }
}

extension BookClub {
    init(record: CKRecord) throws {
        self.init(
            id: try record.uuid(for: CloudKitField.Shared.id),
            name: try record.string(for: CloudKitField.BookClub.name),
            photoAssetName: record.optionalString(for: CloudKitField.BookClub.photoAssetName),
            activeBookID: try record.uuid(for: CloudKitField.BookClub.activeBookID),
            inviteCode: try record.string(for: CloudKitField.BookClub.inviteCode),
            createdAt: try record.date(for: CloudKitField.BookClub.createdAt)
        )
    }
}

extension Membership {
    init(record: CKRecord) throws {
        let roleValue = try record.string(for: CloudKitField.Membership.role)

        self.init(
            id: try record.uuid(for: CloudKitField.Shared.id),
            userID: try record.uuid(for: CloudKitField.Membership.userID),
            clubID: try record.uuid(for: CloudKitField.Membership.clubID),
            role: MembershipRole(rawValue: roleValue) ?? .member,
            joinedAt: try record.date(for: CloudKitField.Membership.joinedAt)
        )
    }
}

extension ReadingProgress {
    init(record: CKRecord) throws {
        self.init(
            id: try record.uuid(for: CloudKitField.Shared.id),
            userID: try record.uuid(for: CloudKitField.ReadingProgress.userID),
            clubID: try record.uuid(for: CloudKitField.ReadingProgress.clubID),
            bookID: try record.uuid(for: CloudKitField.ReadingProgress.bookID),
            currentPage: record[CloudKitField.ReadingProgress.currentPage] as? Int ?? 0,
            updatedAt: try record.date(for: CloudKitField.ReadingProgress.updatedAt)
        )
    }
}

extension Comment {
    init(record: CKRecord) throws {
        self.init(
            id: try record.uuid(for: CloudKitField.Shared.id),
            clubID: try record.uuid(for: CloudKitField.Comment.clubID),
            authorID: try record.uuid(for: CloudKitField.Comment.authorID),
            body: try record.string(for: CloudKitField.Comment.body),
            pageReference: record[CloudKitField.Comment.pageReference] as? Int ?? 0,
            createdAt: try record.date(for: CloudKitField.Comment.createdAt)
        )
    }
}

extension Reply {
    init(record: CKRecord) throws {
        self.init(
            id: try record.uuid(for: CloudKitField.Shared.id),
            commentID: try record.uuid(for: CloudKitField.Reply.commentID),
            authorID: try record.uuid(for: CloudKitField.Reply.authorID),
            body: try record.string(for: CloudKitField.Reply.body),
            createdAt: try record.date(for: CloudKitField.Reply.createdAt)
        )
    }
}

private extension CKRecord {
    func string(for field: String) throws -> String {
        guard let value = self[field] as? String else {
            throw CloudKitRecordMappingError.missingField(field)
        }

        return value
    }

    func optionalString(for field: String) -> String? {
        self[field] as? String
    }

    func uuid(for field: String) throws -> UUID {
        let value = try string(for: field)

        guard let uuid = UUID(uuidString: value) else {
            throw CloudKitRecordMappingError.invalidField(field)
        }

        return uuid
    }

    func date(for field: String) throws -> Date {
        guard let value = self[field] as? Date else {
            throw CloudKitRecordMappingError.missingField(field)
        }

        return value
    }
}
