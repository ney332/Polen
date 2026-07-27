import Foundation

protocol BookMetadataStore: Sendable {
    func save(_ book: Book) async throws
    func savedBooks() async throws -> [Book]
}
