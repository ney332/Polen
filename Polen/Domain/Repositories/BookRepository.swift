import Foundation

protocol BookRepository: Sendable {
    func searchBooks(query: String) async throws -> [Book]
    func saveBook(_ book: Book) async throws
}
