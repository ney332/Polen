import Foundation

enum ClubFlowError: LocalizedError, Equatable {
    case missingAuthenticatedUser
    case missingClubName
    case missingBook
    case invalidInviteCode

    var errorDescription: String? {
        switch self {
        case .missingAuthenticatedUser:
            "Entre novamente para continuar."
        case .missingClubName:
            "Informe o nome do clube."
        case .missingBook:
            "Selecione um livro para o clube."
        case .invalidInviteCode:
            "Informe um código de convite válido."
        }
    }
}
