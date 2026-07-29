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

    @State private var isActionMenuExpanded = false
    @State private var isShowingCommentComposer = false
    @State private var isShowingProgressEditor = false

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
        .sheet(isPresented: $isShowingCommentComposer) {
            NavigationStack {
                CommentComposerView(
                    bodyText: $newCommentBody,
                    pageText: $newCommentPageText,
                    currentPage: summary.readingProgress.currentPage,
                    createAction: createCommentAction
                )
                .padding(PollenSpacing.large)
                .navigationTitle("Novo comentário")
                .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $isShowingProgressEditor) {
            NavigationStack {
                ReadingProgressSummaryView(
                    progress: summary.readingProgress,
                    pageCount: summary.activeBook.pageCount,
                    updateAction: updateProgressAction
                )
                .padding(PollenSpacing.large)
                .navigationTitle("Atualizar progresso")
                .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDetents([.medium])
        }
    }

    private var floatingActions: some View {
        VStack(alignment: .trailing, spacing: PollenSpacing.small) {
            if isActionMenuExpanded {
                Button {
                    isShowingCommentComposer = true
                    isActionMenuExpanded = false
                } label: {
                    Label("Novo comentário", systemImage: "text.bubble")
                        .padding(.horizontal, PollenSpacing.medium)
                        .padding(.vertical, PollenSpacing.small)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    isShowingProgressEditor = true
                    isActionMenuExpanded = false
                } label: {
                    Label("Atualizar progresso", systemImage: "bookmark")
                        .padding(.horizontal, PollenSpacing.medium)
                        .padding(.vertical, PollenSpacing.small)
                }
                .buttonStyle(.borderedProminent)
            }

            Button {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.82)) {
                    isActionMenuExpanded.toggle()
                }
            } label: {
                Image(systemName: isActionMenuExpanded ? "xmark" : "plus")
                    .font(.system(size: 28, weight: .semibold))
                    .frame(width: 72, height: 72)
            }
            .buttonStyle(.borderedProminent)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.18), radius: 12, x: 0, y: 6)
            .accessibilityLabel(isActionMenuExpanded ? "Fechar ações" : "Abrir ações do clube")
        }
    }
}
