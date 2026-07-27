import Foundation

actor DefaultBookRepository: BookRepository {
    private let googleBooksClient: GoogleBooksClient
    private let metadataStore: BookMetadataStore

    init(
        googleBooksClient: GoogleBooksClient = DefaultGoogleBooksClient(),
        metadataStore: BookMetadataStore = UserDefaultsBookMetadataStore()
    ) {
        self.googleBooksClient = googleBooksClient
        self.metadataStore = metadataStore
    }

    func searchBooks(query: String) async throws -> [Book] {
        try await googleBooksClient.search(query: query)
    }

    func saveBook(_ book: Book) async throws {
        try await metadataStore.save(book)
    }
}
