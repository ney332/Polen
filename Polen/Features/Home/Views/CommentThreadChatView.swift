import SwiftUI

struct CommentThreadChatView: View {
    let comment: Comment
    let replyState: ReplyThreadState
    @Binding var replyDraft: String
    let loadAction: () async -> Void
    let createReplyAction: () async -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PollenSpacing.medium) {
                VStack(alignment: .leading, spacing: PollenSpacing.small) {
                    Label("Página \(comment.pageReference)", systemImage: "bookmark")
                        .font(PollenTypography.caption)
                        .foregroundStyle(PollenColors.primary)

                    Text(comment.body)
                        .font(PollenTypography.headline)
                        .foregroundStyle(PollenColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(comment.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(PollenTypography.caption)
                        .foregroundStyle(PollenColors.textSecondary)
                }
                .padding(PollenSpacing.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(PollenColors.groupedBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                repliesContent
            }
            .padding(PollenSpacing.large)
            .padding(.bottom, 72)
        }
        .background(PollenColors.background)
        .navigationTitle("Discussão")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            ReplyComposerView(
                bodyText: $replyDraft,
                createAction: createReplyAction
            )
            .padding(PollenSpacing.medium)
            .background(.bar)
        }
        .task {
            await loadAction()
        }
    }

    @ViewBuilder
    private var repliesContent: some View {
        switch replyState {
        case .collapsed, .loading:
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.top, PollenSpacing.large)
        case .empty:
            Text("Nenhuma resposta ainda.")
                .font(PollenTypography.body)
                .foregroundStyle(PollenColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, PollenSpacing.large)
        case .failed(let message):
            Text(message)
                .font(PollenTypography.caption)
                .foregroundStyle(.red)
        case .loaded(let replies):
            VStack(alignment: .leading, spacing: PollenSpacing.small) {
                ForEach(replies) { reply in
                    ReplyMessageBubbleView(reply: reply)
                }
            }
        }
    }
}

private struct ReplyMessageBubbleView: View {
    let reply: Reply

    var body: some View {
        VStack(alignment: .leading, spacing: PollenSpacing.xSmall) {
            Text(reply.body)
                .font(PollenTypography.body)
                .foregroundStyle(PollenColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(reply.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(PollenTypography.caption)
                .foregroundStyle(PollenColors.textSecondary)
        }
        .padding(PollenSpacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PollenColors.groupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
