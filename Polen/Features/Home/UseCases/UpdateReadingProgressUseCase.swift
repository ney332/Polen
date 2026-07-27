import Foundation

struct UpdateReadingProgressUseCase: Sendable {
    private let readingProgressRepository: ReadingProgressRepository

    init(readingProgressRepository: ReadingProgressRepository) {
        self.readingProgressRepository = readingProgressRepository
    }

    func execute(
        currentProgress: ReadingProgress,
        newPage: Int,
        pageCount: Int?
    ) async throws -> ReadingProgress {
        guard newPage >= 0 else {
            throw DomainError.invalidReadingProgress
        }

        if let pageCount, pageCount > 0, newPage > pageCount {
            throw DomainError.invalidReadingProgress
        }

        var updatedProgress = currentProgress
        updatedProgress.currentPage = newPage
        updatedProgress.updatedAt = .now

        return try await readingProgressRepository.updateProgress(updatedProgress)
    }
}
