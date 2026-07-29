import SwiftUI

struct ClubCommentsPreviewView: View {
    let commentState: CommentTimelineState
    let replyStates: [UUID: ReplyThreadState]
    let currentUserID: UUID?
    let currentPage: Int
    @Binding var replyDrafts: [UUID: String]
    let updateAction: (Comment, String) async -> Void
    let deleteAction: (Comment) async -> Void
    let prepareReplyThreadAction: (Comment) async -> Void
    let createReplyAction: (Comment) async -> Void

    @State private var selectedComment: Comment?

    var body: some View {
        VStack(alignment: .leading, spacing: PollenSpacing.medium) {
            Text("Comentários")
                .font(PollenTypography.headline)

            timeline
        }
        .navigationDestination(item: $selectedComment) { comment in
            CommentThreadChatView(
                comment: comment,
                replyState: replyStates[comment.id] ?? .collapsed,
                replyDraft: replyDraftBinding(for: comment.id),
                loadAction: {
                    await prepareReplyThreadAction(comment)
                },
                createReplyAction: {
                    await createReplyAction(comment)
                }
            )
        }
    }

    @ViewBuilder
    private var timeline: some View {
        switch commentState {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity)
        case .empty:
            HStack(alignment: .top, spacing: PollenSpacing.small) {
                Image(systemName: "eye.slash")
                    .foregroundStyle(PollenColors.primary)

                Text("Nenhum comentário visível para o seu progresso atual.")
                    .font(PollenTypography.body)
                    .foregroundStyle(PollenColors.textSecondary)
            }
        case .failed(let message):
            Text(message)
                .font(PollenTypography.caption)
                .foregroundStyle(.red)
        case .loaded(let comments):
            VStack(spacing: PollenSpacing.small) {
                ForEach(comments) { comment in
                    CommentTimelineRowView(
                        comment: comment,
                        canEdit: comment.authorID == currentUserID,
                        isSpoilerLocked: comment.pageReference > currentPage,
                        updateAction: { body in
                            await updateAction(comment, body)
                        },
                        deleteAction: {
                            await deleteAction(comment)
                        },
                        replyAction: {
                            selectedComment = comment
                        }
                    )
                }
            }
        }
    }

    private func replyDraftBinding(for commentID: UUID) -> Binding<String> {
        Binding(
            get: {
                replyDrafts[commentID] ?? ""
            },
            set: { newValue in
                replyDrafts[commentID] = newValue
            }
        )
    }
}
