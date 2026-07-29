import Foundation

enum InviteLinkParser {
    static func makeInviteURL(inviteCode: String) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "polen-ck0.pages.dev"
        components.path = "/join/"
        components.queryItems = [
            URLQueryItem(name: "code", value: inviteCode)
        ]
        return components.url ?? URL(string: "https://polen-ck0.pages.dev/join/?code=\(inviteCode)")!
    }

    static func makeAppInviteURL(inviteCode: String) -> URL {
        var components = URLComponents()
        components.scheme = "polen"
        components.host = "join"
        components.queryItems = [
            URLQueryItem(name: "code", value: inviteCode)
        ]
        return components.url ?? URL(string: "polen://join?code=\(inviteCode)")!
    }

    static func inviteCode(from url: URL) -> String? {
        guard isSupportedInviteURL(url) else {
            return nil
        }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)

        guard let code = components?.queryItems?.first(where: { $0.name == "code" })?.value,
              !code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        return code
    }

    private static func isSupportedInviteURL(_ url: URL) -> Bool {
        let scheme = url.scheme?.lowercased()
        let host = url.host?.lowercased()

        if scheme == "polen", host == "join" {
            return true
        }

        if scheme == "https",
           ["polen.app", "polen-ck0.pages.dev"].contains(host),
           ["/join", "/join/"].contains(url.path) {
            return true
        }

        return false
    }
}
