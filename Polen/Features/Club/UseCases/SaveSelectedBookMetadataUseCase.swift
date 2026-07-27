import Foundation

struct SaveSelectedBookMetadataUseCase: Sendable {
    private let bookRepository: BookRepository

    init(bookRepository: BookRepository) {
        self.bookRepository = bookRepository
    }

    func execute(book: Book) async throws {
        try await bookRepository.saveBook(book)
    }
}
