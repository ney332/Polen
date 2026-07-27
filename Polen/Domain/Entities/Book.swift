import Foundation

struct Book: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var googleBooksID: String
    var title: String
    var authors: [String]
    var isbn: String?
    var description: String?
    var pageCount: Int?
    var coverURL: URL?

    init(
        id: UUID = UUID(),
        googleBooksID: String,
        title: String,
        authors: [String] = [],
        isbn: String? = nil,
        description: String? = nil,
        pageCount: Int? = nil,
        coverURL: URL? = nil
    ) {
        self.id = id
        self.googleBooksID = googleBooksID
        self.title = title
        self.authors = authors
        self.isbn = isbn
        self.description = description
        self.pageCount = pageCount
        self.coverURL = coverURL
    }
}
