import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    private(set) var state: HomeState = .loading
    private(set) var commentState: CommentTimelineState = .loading
    var newCommentBody = ""
    var newCommentPageText = ""

    private let appState: AppState
    private let router: AppRouter
    private let resolveHomeStateUseCase: ResolveHomeStateUseCase
    private let loadClubHomeSummaryUseCase: LoadClubHomeSummaryUseCase
    private let updateReadingProgressUseCase: UpdateReadingProgressUseCase
    private let loadVisibleCommentsUseCase: LoadVisibleCommentsUseCase
    private let createCommentUseCase: CreateCommentUseCase
    private let updateCommentUseCase: UpdateCommentUseCase
    private let deleteCommentUseCase: DeleteCommentUseCase

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
    }

    func load() async {
        guard let userID = appState.currentUser?.id else {
            state = .failed(DomainError.unauthenticated.localizedDescription)
            return
        }

        let resolvedState = resolveHomeStateUseCase.execute(currentClubID: appState.currentClubID)
        state = .loading

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

            appState.enterClub(id: summary.id)
            appState.readingProgress = summary.readingProgress
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
        router.navigate(to: .joinClub)
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
            _ = try await createCommentUseCase.execute(
                clubID: summary.id,
                authorID: userID,
                body: newCommentBody,
                pageReference: Int(newCommentPageText) ?? summary.readingProgress.currentPage
            )
            newCommentBody = ""
            await loadVisibleComments(for: summary)
        } catch {
            commentState = .failed(error.localizedDescription)
        }
    }

    func updateComment(_ comment: Comment, body: String) async {
        guard case .club(let summary) = state else {
            return
        }

        do {
            _ = try await updateCommentUseCase.execute(comment: comment, body: body)
            await loadVisibleComments(for: summary)
        } catch {
            commentState = .failed(error.localizedDescription)
        }
    }

    func deleteComment(_ comment: Comment) async {
        guard case .club(let summary) = state else {
            return
        }

        do {
            try await deleteCommentUseCase.execute(commentID: comment.id)
            await loadVisibleComments(for: summary)
        } catch {
            commentState = .failed(error.localizedDescription)
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
        } catch {
            commentState = .failed(error.localizedDescription)
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
