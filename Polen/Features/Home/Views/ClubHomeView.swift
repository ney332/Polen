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
    let prepareReplyThreadAction: (Comment) async -> Void
    let createReplyAction: (Comment) async -> Void

    @State private var isShowingClubActions = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: PollenSpacing.medium) {
                    ClubHeaderView(summary: summary)
                    ActiveBookView(book: summary.activeBook)
                    ClubCommentsPreviewView(
                        commentState: commentState,
                        replyStates: replyStates,
                        currentUserID: currentUserID,
                        currentPage: summary.readingProgress.currentPage,
                        replyDrafts: $replyDrafts,
                        updateAction: updateCommentAction,
                        deleteAction: deleteCommentAction,
                        prepareReplyThreadAction: prepareReplyThreadAction,
                        createReplyAction: createReplyAction
                    )
                }
                .padding(PollenSpacing.large)
                .padding(.bottom, 104)
            }

            floatingActions
                .padding(PollenSpacing.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PollenColors.background)
        .sheet(isPresented: $isShowingClubActions) {
            NavigationStack {
                ClubActionSheetView(
                    summary: summary,
                    newCommentBody: $newCommentBody,
                    newCommentPageText: $newCommentPageText,
                    updateProgressAction: updateProgressAction,
                    createCommentAction: createCommentAction
                )
            }
            .presentationDetents([.large])
        }
    }

    private var floatingActions: some View {
        Button {
            isShowingClubActions = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 28, weight: .semibold))
                .frame(width: 72, height: 72)
        }
        .buttonStyle(.borderedProminent)
        .clipShape(Circle())
        .shadow(color: .black.opacity(0.18), radius: 12, x: 0, y: 6)
        .accessibilityLabel("Abrir ações do clube")
    }
}
