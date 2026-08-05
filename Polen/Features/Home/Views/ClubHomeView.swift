import SwiftUI

struct ClubHomeView: View {
    let summary: HomeClubSummary
    let commentState: CommentTimelineState
    let replyStates: [UUID: ReplyThreadState]
    let currentUserID: UUID?
    @Binding var newCommentBody: String
    @Binding var newCommentAudioData: Data?
    @Binding var newCommentAudioDuration: TimeInterval?
    @Binding var newCommentPageText: String
    @Binding var replyDrafts: [UUID: String]
    @Binding var replyAudioData: [UUID: Data]
    @Binding var replyAudioDurations: [UUID: TimeInterval]
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
                    if let activeBook = summary.activeBook,
                       let readingProgress = summary.readingProgress {
//                        ActiveBookView(book: activeBook) // ViewModel do livro que aparece na home
                        ClubCommentsPreviewView(
                            commentState: commentState,
                            replyStates: replyStates,
                            currentUserID: currentUserID,
                        currentPage: readingProgress.currentPage,
                        replyDrafts: $replyDrafts,
                        replyAudioData: $replyAudioData,
                        replyAudioDurations: $replyAudioDurations,
                        updateAction: updateCommentAction,
                            deleteAction: deleteCommentAction,
                            prepareReplyThreadAction: prepareReplyThreadAction,
                            createReplyAction: createReplyAction
                        )
                    } else {
                        NoActiveBookView()
                    }
                }
                .padding(PollenSpacing.large)
                .padding(.bottom, 104)
            }

            if summary.activeBook != nil, summary.readingProgress != nil {
                floatingActions
                    .padding(PollenSpacing.large)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PollenColors.background)
        .sheet(isPresented: $isShowingClubActions) {
            NavigationStack {
                ClubActionSheetView(
                    summary: summary,
                    newCommentBody: $newCommentBody,
                    newCommentAudioData: $newCommentAudioData,
                    newCommentAudioDuration: $newCommentAudioDuration,
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

private struct NoActiveBookView: View {
    var body: some View {
        ContentUnavailableView(
            "Nenhum livro escolhido",
            systemImage: "book.closed",
            description: Text("Abra Meu Clube no perfil para escolher o livro ativo.")
        )
        .frame(maxWidth: .infinity, minHeight: 280)
        .background(PollenColors.groupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
