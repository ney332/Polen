import Foundation

protocol GoogleBooksClient: Sendable {
    func search(query: String) async throws -> [Book]
}

struct DefaultGoogleBooksClient: GoogleBooksClient {
    private let urlSession: URLSession
    private let configuration: GoogleBooksConfiguration

    init(
        urlSession: URLSession = .shared,
        configuration: GoogleBooksConfiguration = .bundle
    ) {
        self.urlSession = urlSession
        self.configuration = configuration
    }

    func search(query: String) async throws -> [Book] {
        guard !configuration.apiKey.trimmed.isEmpty else {
            throw GoogleBooksError.missingAPIKey
        }

        var components = URLComponents(
            url: AppConstants.googleBooksBaseURL.appending(path: "volumes"),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "printType", value: "books"),
            URLQueryItem(name: "maxResults", value: "20"),
            URLQueryItem(name: "key", value: configuration.apiKey)
        ]

        guard let url = components?.url else {
            throw GoogleBooksError.invalidURL
        }

        let (data, urlResponse) = try await urlSession.data(from: url)

        guard let httpResponse = urlResponse as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw GoogleBooksError.invalidResponse
        }

        let decodedResponse = try JSONDecoder().decode(GoogleBooksResponseDTO.self, from: data)

        return decodedResponse.items?.map(mapBook) ?? []
    }

    private func mapBook(from item: GoogleBookItemDTO) -> Book {
        let isbn = item.volumeInfo.industryIdentifiers?
            .first { $0.type == "ISBN_13" || $0.type == "ISBN_10" }?
            .identifier

        return Book(
            googleBooksID: item.id,
            title: item.volumeInfo.title,
            authors: item.volumeInfo.authors ?? [],
            isbn: isbn,
            description: item.volumeInfo.description,
            pageCount: item.volumeInfo.pageCount,
            coverURL: item.volumeInfo.imageLinks?.preferredCoverURL
        )
    }
}
