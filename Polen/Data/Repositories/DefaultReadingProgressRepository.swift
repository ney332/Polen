import Foundation

actor DefaultReadingProgressRepository: ReadingProgressRepository {
    private let cloudKitStore: CloudKitReadingProgressStoring

    init(cloudKitStore: CloudKitReadingProgressStoring) {
        self.cloudKitStore = cloudKitStore
    }

    func updateProgress(_ progress: ReadingProgress) async throws -> ReadingProgress {
        try await cloudKitStore.updateProgress(progress)
    }
}
