import Foundation

actor UserDefaultsBookMetadataStore: BookMetadataStore {
    private let userDefaults: UserDefaults
    private let storageKey = "selected-google-books-metadata"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func save(_ book: Book) async throws {
        var books = try await savedBooks()

        if let index = books.firstIndex(where: { $0.googleBooksID == book.googleBooksID }) {
            books[index] = book
        } else {
            books.append(book)
        }

        let data = try encoder.encode(books)
        userDefaults.set(data, forKey: storageKey)
    }

    func savedBooks() async throws -> [Book] {
        guard let data = userDefaults.data(forKey: storageKey) else {
            return []
        }

        return try decoder.decode([Book].self, from: data)
    }
}
