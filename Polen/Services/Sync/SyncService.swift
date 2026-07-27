import Foundation

protocol SyncService: Sendable {
    func synchronize() async throws
}

struct CloudKitSyncService: SyncService {
    func synchronize() async throws {
    }
}
