import SwiftUI

struct ClubHomeView: View {
    let summary: HomeClubSummary
    let commentState: CommentTimelineState
    let replyStates: [UUID: ReplyThreadState]
    let currentUserID: UUID?
    @Binding var newCommentBody: String
    @Binding var newCommentPageText: String
    @Binding var replyDrafts: [UUID: String]
    let updateProgressAction: (Int) async -> Void
    let createCommentAction: () async -> Void
    let updateCommentAction: (Comment, String) async -> Void
    let deleteCommentAction: (Comment) async -> Void
    let toggleRepliesAction: (Comment) async -> Void
    let createReplyAction: (Comment) async -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PollenSpacing.medium) {
                ClubHeaderView(summary: summary)
                ActiveBookView(book: summary.activeBook)
                ReadingProgressSummaryView(
                    progress: summary.readingProgress,
                    pageCount: summary.activeBook.pageCount,
                    updateAction: updateProgressAction
                )
                ClubMembersPreviewView(
                    memberCount: summary.memberCount,
                    inviteCode: summary.inviteCode
                )
                ClubCommentsPreviewView(
                    commentState: commentState,
                    replyStates: replyStates,
                    currentUserID: currentUserID,
                    newCommentBody: $newCommentBody,
                    newCommentPageText: $newCommentPageText,
                    replyDrafts: $replyDrafts,
                    currentPage: summary.readingProgress.currentPage,
                    createAction: createCommentAction,
                    updateAction: updateCommentAction,
                    deleteAction: deleteCommentAction,
                    toggleRepliesAction: toggleRepliesAction,
                    createReplyAction: createReplyAction
                )
            }
            .padding(PollenSpacing.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PollenColors.background)
    }
}
