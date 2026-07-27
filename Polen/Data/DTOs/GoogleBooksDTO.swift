import Foundation

struct GoogleBooksResponseDTO: Decodable {
    let items: [GoogleBookItemDTO]?
}

struct GoogleBookItemDTO: Decodable {
    let id: String
    let volumeInfo: GoogleBookVolumeInfoDTO
}

struct GoogleBookVolumeInfoDTO: Decodable {
    let title: String
    let authors: [String]?
    let description: String?
    let pageCount: Int?
    let industryIdentifiers: [GoogleBookIdentifierDTO]?
    let imageLinks: GoogleBookImageLinksDTO?
}

struct GoogleBookIdentifierDTO: Decodable {
    let type: String
    let identifier: String
}

struct GoogleBookImageLinksDTO: Decodable {
    let thumbnail: URL?
    let smallThumbnail: URL?
}

extension GoogleBookImageLinksDTO {
    var preferredCoverURL: URL? {
        thumbnail?.usingHTTPS ?? smallThumbnail?.usingHTTPS
    }
}

private extension URL {
    var usingHTTPS: URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              components.scheme == "http" else {
            return self
        }

        components.scheme = "https"
        return components.url ?? self
    }
}
