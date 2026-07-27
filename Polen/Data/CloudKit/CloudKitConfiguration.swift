import CloudKit

struct CloudKitConfiguration: Sendable {
    let containerIdentifier: String

    static let production = CloudKitConfiguration(
        containerIdentifier: AppConstants.cloudKitContainerIdentifier
    )
}

protocol CloudKitContainerProviding: Sendable {
    func container() -> CKContainer
    func database(for scope: CloudKitDatabaseScope) -> CKDatabase
}

enum CloudKitDatabaseScope: Sendable {
    case `private`
    case `public`
    case shared
}

struct DefaultCloudKitContainerProvider: CloudKitContainerProviding {
    private let configuration: CloudKitConfiguration

    init(configuration: CloudKitConfiguration) {
        self.configuration = configuration
    }

    func container() -> CKContainer {
        CKContainer(identifier: configuration.containerIdentifier)
    }

    func database(for scope: CloudKitDatabaseScope) -> CKDatabase {
        switch scope {
        case .private:
            container().privateCloudDatabase
        case .public:
            container().publicCloudDatabase
        case .shared:
            container().sharedCloudDatabase
        }
    }
}
