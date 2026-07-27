import SwiftUI

struct ClubCommentsPreviewView: View {
    let commentState: CommentTimelineState
    let currentUserID: UUID?
    @Binding var newCommentBody: String
    @Binding var newCommentPageText: String
    let currentPage: Int
    let createAction: () async -> Void
    let updateAction: (Comment, String) async -> Void
    let deleteAction: (Comment) async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: PollenSpacing.medium) {
            Text("Comentários")
                .font(PollenTypography.headline)

            CommentComposerView(
                bodyText: $newCommentBody,
                pageText: $newCommentPageText,
                currentPage: currentPage,
                createAction: createAction
            )

            Divider()

            timeline
        }
        .padding(PollenSpacing.medium)
        .background(PollenColors.groupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
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
                        updateAction: { body in
                            await updateAction(comment, body)
                        },
                        deleteAction: {
                            await deleteAction(comment)
                        }
                    )
                }
            }
        }
    }
}
