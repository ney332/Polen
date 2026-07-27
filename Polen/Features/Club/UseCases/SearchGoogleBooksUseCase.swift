import Foundation

struct SearchGoogleBooksUseCase: Sendable {
    private let bookRepository: BookRepository

    init(bookRepository: BookRepository) {
        self.bookRepository = bookRepository
    }

    func execute(query: String) async throws -> [Book] {
        let sanitizedQuery = query.trimmed

        guard !sanitizedQuery.isEmpty else {
            return []
        }

        return try await bookRepository.searchBooks(query: sanitizedQuery)
    }
}
