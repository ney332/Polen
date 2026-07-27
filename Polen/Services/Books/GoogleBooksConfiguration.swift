import Foundation

struct GoogleBooksConfiguration: Sendable {
    let apiKey: String

    static var bundle: GoogleBooksConfiguration {
        GoogleBooksConfiguration(
            apiKey: Bundle.main.object(forInfoDictionaryKey: "GOOGLE_BOOKS_API_KEY") as? String ?? ""
        )
    }
}
