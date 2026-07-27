import Foundation

enum InviteCodeGenerator {
    static func makeCode(from clubName: String) -> String {
        let prefix = clubName
            .uppercased()
            .filter { $0.isLetter || $0.isNumber }
            .prefix(3)

        return "\(prefix)-\(Int.random(in: 1000...9999))"
    }
}
