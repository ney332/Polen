import SwiftUI

struct CommentThreadChatView: View {
    let comment: Comment
    let replyState: ReplyThreadState
    let currentUserID: UUID?
    @Binding var replyDraft: String
    @Binding var replyAudioData: Data?
    @Binding var replyAudioDuration: TimeInterval?
    let loadAction: () async -> Void
    let createReplyAction: () async -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PollenSpacing.medium) {
                HStack(alignment: .top, spacing: PollenSpacing.small) {
                    AuthorAvatarView(
                        imageData: comment.authorAvatarImageData,
                        symbolName: comment.authorAvatarAssetName,
                        size: 40
                    )

                    VStack(alignment: .leading, spacing: PollenSpacing.xSmall) {
                        Text(comment.authorDisplayName ?? "Leitor")
                            .font(PollenTypography.headline)

                        Label("Página \(comment.pageReference)", systemImage: "bookmark")
                            .font(PollenTypography.caption)
                            .foregroundStyle(PollenColors.primary)

                        if !comment.body.isEmpty {
                            Text(comment.body)
                                .font(PollenTypography.body)
                                .foregroundStyle(PollenColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        if let audioData = comment.audioData {
                            AudioPlaybackView(audioData: audioData, duration: comment.audioDuration)
                        }

                        Text(comment.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .font(PollenTypography.caption)
                            .foregroundStyle(PollenColors.textSecondary)
                    }
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
                audioData: $replyAudioData,
                audioDuration: $replyAudioDuration,
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
            VStack(spacing: PollenSpacing.small) {
                ForEach(replies) { reply in
                    ReplyMessageBubbleView(
                        reply: reply,
                        isCurrentUser: reply.authorID == currentUserID
                    )
                }
            }
        }
    }
}

private struct ReplyMessageBubbleView: View {
    let reply: Reply
    let isCurrentUser: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: PollenSpacing.small) {
            if isCurrentUser {
                Spacer(minLength: 48)
            } else {
                AuthorAvatarView(
                    imageData: reply.authorAvatarImageData,
                    symbolName: reply.authorAvatarAssetName,
                    size: 32
                )
            }

            VStack(alignment: .leading, spacing: PollenSpacing.xSmall) {
                if !isCurrentUser {
                    Text(reply.authorDisplayName ?? "Leitor")
                        .font(PollenTypography.caption)
                        .foregroundStyle(PollenColors.primary)
                }

                if !reply.body.isEmpty {
                    Text(reply.body)
                        .font(PollenTypography.body)
                        .foregroundStyle(PollenColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let audioData = reply.audioData {
                    AudioPlaybackView(audioData: audioData, duration: reply.audioDuration)
                }

                Text(reply.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(PollenTypography.caption)
                    .foregroundStyle(PollenColors.textSecondary)
            }
            .padding(PollenSpacing.small)
            .background(isCurrentUser ? PollenColors.primary.opacity(0.18) : PollenColors.groupedBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            if !isCurrentUser {
                Spacer(minLength: 48)
            }
        }
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
    }
}
