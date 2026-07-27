import Foundation
import Security

enum KeychainAuthenticationSessionStoreError: LocalizedError {
    case unexpectedStatus(OSStatus)

    var errorDescription: String? {
        switch self {
        case .unexpectedStatus(let status):
            "Keychain retornou status inesperado: \(status)."
        }
    }
}

actor KeychainAuthenticationSessionStore: AuthenticationSessionStore {
    private let service = "br.com.polen.authentication"
    private let account = "current-user-profile"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func loadUserProfile() async throws -> UserProfile? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            throw KeychainAuthenticationSessionStoreError.unexpectedStatus(status)
        }

        guard let data = result as? Data else {
            return nil
        }

        return try decoder.decode(UserProfile.self, from: data)
    }

    func save(userProfile: UserProfile) async throws {
        let data = try encoder.encode(userProfile)

        var query = baseQuery
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if updateStatus == errSecItemNotFound {
            query.merge(attributes) { _, new in new }
            let addStatus = SecItemAdd(query as CFDictionary, nil)

            guard addStatus == errSecSuccess else {
                throw KeychainAuthenticationSessionStoreError.unexpectedStatus(addStatus)
            }

            return
        }

        guard updateStatus == errSecSuccess else {
            throw KeychainAuthenticationSessionStoreError.unexpectedStatus(updateStatus)
        }
    }

    func clear() async throws {
        let status = SecItemDelete(baseQuery as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainAuthenticationSessionStoreError.unexpectedStatus(status)
        }
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
