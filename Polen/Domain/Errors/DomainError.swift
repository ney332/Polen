import Foundation

enum DomainError: LocalizedError, Equatable {
    case unauthenticated
    case notClubMember
    case userAlreadyHasClub
    case invalidInviteCode
    case invalidReadingProgress
    case emptyComment
    case invalidAppleCredential

    var errorDescription: String? {
        switch self {
        case .unauthenticated:
            "Usuário não autenticado."
        case .notClubMember:
            "Apenas membros do clube podem realizar esta ação."
        case .userAlreadyHasClub:
            "Cada usuário pode participar de apenas um clube."
        case .invalidInviteCode:
            "Código de convite inválido."
        case .invalidReadingProgress:
            "O progresso de leitura informado é inválido."
        case .emptyComment:
            "O comentário não pode estar vazio."
        case .invalidAppleCredential:
            "Não foi possível validar a credencial da Apple."
        }
    }
}
