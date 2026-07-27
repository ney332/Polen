import Foundation

actor DefaultClubHomeRepository: ClubHomeRepository {
    private let cloudKitStore: CloudKitClubHomeStoring

    init(cloudKitStore: CloudKitClubHomeStoring) {
        self.cloudKitStore = cloudKitStore
    }

    func currentSummary(for userID: UUID) async throws -> HomeClubSummary? {
        try await cloudKitStore.currentSummary(for: userID)
    }

    func summary(for clubID: UUID, userID: UUID) async throws -> HomeClubSummary {
        try await cloudKitStore.summary(for: clubID, userID: userID)
    }
}
