import Foundation

enum GoogleBooksError: LocalizedError, Equatable {
    case missingAPIKey
    case invalidURL
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            "A chave da Google Books API não foi configurada."
        case .invalidURL:
            "Não foi possível montar a URL de pesquisa."
        case .invalidResponse:
            "A Google Books API retornou uma resposta inválida."
        }
    }
}
