import Foundation

enum CreateClubStep: Int, CaseIterable {
    case name
    case photo
    case book
    case invite
    case review

    var title: String {
        switch self {
        case .name:
            "Nome"
        case .photo:
            "Foto"
        case .book:
            "Livro"
        case .invite:
            "Convites"
        case .review:
            "Revisão"
        }
    }
}
