import Foundation

protocol ReadingProgressRepository: Sendable {
    func updateProgress(_ progress: ReadingProgress) async throws -> ReadingProgress
}
