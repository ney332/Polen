import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    private(set) var state: HomeState = .loading
    private(set) var commentState: CommentTimelineState = .loading
    private(set) var replyStates: [UUID: ReplyThreadState] = [:]
    var newCommentBody = ""
    var newCommentPageText = ""
    var replyDrafts: [UUID: String] = [:]

    private let appState: AppState
    private let router: AppRouter
    private let resolveHomeStateUseCase: ResolveHomeStateUseCase
    private let loadClubHomeSummaryUseCase: LoadClubHomeSummaryUseCase
    private let updateReadingProgressUseCase: UpdateReadingProgressUseCase
    private let loadVisibleCommentsUseCase: LoadVisibleCommentsUseCase
    private let createCommentUseCase: CreateCommentUseCase
    private let updateCommentUseCase: UpdateCommentUseCase
    private let deleteCommentUseCase: DeleteCommentUseCase
    private let loadRepliesUseCase: LoadRepliesUseCase
    private let createReplyUseCase: CreateReplyUseCase

    var displayName: String {
        appState.currentUser?.displayName ?? "Leitor"
    }

    var currentUserID: UUID? {
        appState.currentUser?.id
    }

    init(
        appState: AppState,
        router: AppRouter,
        clubHomeRepository: ClubHomeRepository,
        readingProgressRepository: ReadingProgressRepository,
        commentRepository: CommentRepository,
        resolveHomeStateUseCase: ResolveHomeStateUseCase = ResolveHomeStateUseCase()
    ) {
        self.appState = appState
        self.router = router
        self.resolveHomeStateUseCase = resolveHomeStateUseCase
        self.loadClubHomeSummaryUseCase = LoadClubHomeSummaryUseCase(clubHomeRepository: clubHomeRepository)
        self.updateReadingProgressUseCase = UpdateReadingProgressUseCase(
            readingProgressRepository: readingProgressRepository
        )
        self.loadVisibleCommentsUseCase = LoadVisibleCommentsUseCase(commentRepository: commentRepository)
        self.createCommentUseCase = CreateCommentUseCase(commentRepository: commentRepository)
        self.updateCommentUseCase = UpdateCommentUseCase(commentRepository: commentRepository)
        self.deleteCommentUseCase = DeleteCommentUseCase(commentRepository: commentRepository)
        self.loadRepliesUseCase = LoadRepliesUseCase(commentRepository: commentRepository)
        self.createReplyUseCase = CreateReplyUseCase(commentRepository: commentRepository)
    }

    func load() async {
        guard let userID = appState.currentUser?.id else {
            state = .failed(DomainError.unauthenticated.localizedDescription)
            return
        }

        if case .club(let summary) = state,
           appState.currentClubSummary == summary {
            return
        }

        if let cachedSummary = appState.currentClubSummary {
            state = .club(cachedSummary)

            if newCommentPageText.isEmpty {
                newCommentPageText = "\(cachedSummary.readingProgress.currentPage)"
            }

            await loadVisibleComments(for: cachedSummary)
        }

        let resolvedState = resolveHomeStateUseCase.execute(currentClubID: appState.currentClubID)

        if appState.currentClubSummary == nil {
            state = .loading
        }

        do {
            let summary: HomeClubSummary?

            switch resolvedState {
            case .club(let placeholderSummary):
                summary = try await loadClubHomeSummaryUseCase.execute(
                    clubID: placeholderSummary.id,
                    userID: userID
                )
            case .empty:
                summary = try await loadClubHomeSummaryUseCase.execute(userID: userID)
            case .loading, .failed:
                summary = nil
            }

            guard let summary else {
                state = .empty
                return
            }

            appState.updateClubSummary(summary)
            state = .club(summary)
            newCommentPageText = "\(summary.readingProgress.currentPage)"
            await loadVisibleComments(for: summary)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func openCreateClub() {
        router.navigate(to: .createClub)
    }

    func openJoinClub() {
        router.navigate(to: .joinClub(nil))
    }

    func openProfile() {
        router.navigate(to: .profile)
    }

    func updateReadingProgress(to newPage: Int) async {
        guard case .club(let summary) = state else {
            return
        }

        do {
            let progress = try await updateReadingProgressUseCase.execute(
                currentProgress: summary.readingProgress,
                newPage: newPage,
                pageCount: summary.activeBook.pageCount
            )
            appState.readingProgress = progress
            let updatedSummary = summary.updating(progress: progress)
            appState.updateClubSummary(updatedSummary)
            state = .club(updatedSummary)
            newCommentPageText = "\(progress.currentPage)"
            await loadVisibleComments(for: updatedSummary)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func createComment() async {
        guard case .club(let summary) = state,
              let userID = appState.currentUser?.id else {
            return
        }

        do {
            newCommentPageText = "\(summary.readingProgress.currentPage)"
            let comment = try await createCommentUseCase.execute(
                clubID: summary.id,
                authorID: userID,
                body: newCommentBody,
                pageReference: summary.readingProgress.currentPage
            )
            newCommentBody = ""
            insertComment(comment)
        } catch {
            commentState = .failed(error.localizedDescription)
        }
    }

    func updateComment(_ comment: Comment, body: String) async {
        guard case .club = state else {
            return
        }

        do {
            let updatedComment = try await updateCommentUseCase.execute(comment: comment, body: body)
            updateCommentInTimeline(updatedComment)
        } catch {
            commentState = .failed(error.localizedDescription)
        }
    }

    func deleteComment(_ comment: Comment) async {
        guard case .club = state else {
            return
        }

        do {
            try await deleteCommentUseCase.execute(commentID: comment.id)
            removeVisibleComment(id: comment.id)
        } catch {
            commentState = .failed(error.localizedDescription)
        }
    }

    func toggleReplies(for comment: Comment) async {
        switch replyStates[comment.id] {
        case .loaded, .empty, .failed, .loading:
            replyStates[comment.id] = .collapsed
        case .collapsed, .none:
            await loadReplies(for: comment.id)
        }
    }

    func prepareReplyThread(for comment: Comment) async {
        switch replyStates[comment.id] {
        case .loaded, .empty, .loading:
            return
        case .failed, .collapsed, .none:
            await loadReplies(for: comment.id)
        }
    }

    func createReply(for comment: Comment) async {
        guard let userID = appState.currentUser?.id else {
            replyStates[comment.id] = .failed(DomainError.unauthenticated.localizedDescription)
            return
        }

        do {
            let reply = try await createReplyUseCase.execute(
                commentID: comment.id,
                authorID: userID,
                body: replyDrafts[comment.id] ?? ""
            )
            replyDrafts[comment.id] = ""
            insertReply(reply, for: comment.id)
        } catch {
            replyStates[comment.id] = .failed(error.localizedDescription)
        }
    }

    private func loadVisibleComments(for summary: HomeClubSummary) async {
        commentState = .loading

        do {
            let comments = try await loadVisibleCommentsUseCase.execute(
                clubID: summary.id,
                readingProgress: summary.readingProgress
            )
            commentState = comments.isEmpty ? .empty : .loaded(comments)
            replyStates = replyStates.filter { commentID, state in
                comments.contains { $0.id == commentID } && state != .collapsed
            }
        } catch {
            commentState = .failed(error.localizedDescription)
        }
    }

    private func loadReplies(for commentID: UUID) async {
        replyStates[commentID] = .loading

        do {
            let replies = try await loadRepliesUseCase.execute(commentID: commentID)
            replyStates[commentID] = replies.isEmpty ? .empty : .loaded(replies)
        } catch {
            replyStates[commentID] = .failed(error.localizedDescription)
        }
    }

    private func insertComment(_ comment: Comment) {
        switch commentState {
        case .loaded(let comments):
            commentState = .loaded((comments + [comment]).sorted { $0.createdAt < $1.createdAt })
        case .empty, .loading, .failed:
            commentState = .loaded([comment])
        }
    }

    private func updateCommentInTimeline(_ comment: Comment) {
        switch commentState {
        case .loaded(let comments):
            let updatedComments = comments.map { $0.id == comment.id ? comment : $0 }
            commentState = .loaded(updatedComments.sorted { $0.createdAt < $1.createdAt })
        case .empty, .loading, .failed:
            commentState = .loaded([comment])
        }
    }

    private func removeVisibleComment(id commentID: UUID) {
        guard case .loaded(let comments) = commentState else {
            return
        }

        let remainingComments = comments.filter { $0.id != commentID }
        commentState = remainingComments.isEmpty ? .empty : .loaded(remainingComments)
        replyStates[commentID] = nil
        replyDrafts[commentID] = nil
    }

    private func insertReply(_ reply: Reply, for commentID: UUID) {
        switch replyStates[commentID] {
        case .loaded(let replies):
            replyStates[commentID] = .loaded((replies + [reply]).sorted { $0.createdAt < $1.createdAt })
        case .empty, .collapsed, .failed, .none:
            replyStates[commentID] = .loaded([reply])
        case .loading:
            replyStates[commentID] = .loaded([reply])
        }
    }
}

extension HomeClubSummary {
    func updating(progress: ReadingProgress) -> HomeClubSummary {
        HomeClubSummary(
            id: id,
            clubName: clubName,
            photoAssetName: photoAssetName,
            inviteCode: inviteCode,
            activeBook: activeBook,
            readingProgress: progress,
            memberCount: memberCount
        )
    }
}
