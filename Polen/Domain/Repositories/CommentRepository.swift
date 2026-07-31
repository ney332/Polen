import Foundation

protocol CommentRepository: Sendable {
    func comments(for clubID: UUID, bookID: UUID) async throws -> [Comment]
    func createComment(_ comment: Comment) async throws
    func updateComment(_ comment: Comment) async throws
    func deleteComment(id: UUID) async throws
    func replies(for commentID: UUID) async throws -> [Reply]
    func createReply(_ reply: Reply) async throws
}
