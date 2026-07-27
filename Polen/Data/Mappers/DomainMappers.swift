import Foundation

extension StoredBook {
    convenience init(book: Book) {
        self.init(
            id: book.id,
            googleBooksID: book.googleBooksID,
            title: book.title,
            authors: book.authors,
            isbn: book.isbn,
            bookDescription: book.description,
            pageCount: book.pageCount,
            coverURL: book.coverURL
        )
    }

    func toDomain() -> Book {
        Book(
            id: id,
            googleBooksID: googleBooksID,
            title: title,
            authors: authors,
            isbn: isbn,
            description: bookDescription,
            pageCount: pageCount,
            coverURL: coverURL
        )
    }
}
