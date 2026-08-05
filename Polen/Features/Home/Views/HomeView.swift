import SwiftUI

struct HomeView: View {
    @Bindable var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 0) {
            HomeGreetingView(displayName: viewModel.displayName)
                .padding(.horizontal, PollenSpacing.large)
                .padding(.top, PollenSpacing.medium)
                .padding(.bottom, PollenSpacing.small)

            content
        }
        .navigationTitle(AppConstants.appName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.openProfile()
                } label: {
                    Image(systemName: "person.crop.circle")
                }
                .accessibilityLabel("Perfil")
            }
        }
        .task {
            await viewModel.load()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            HomeLoadingView()
        case .empty:
            EmptyHomeView(
                createAction: viewModel.openCreateClub,
                joinAction: viewModel.openJoinClub
            )
        case .club:
            if case .club(let summary) = viewModel.state {
                ClubHomeView(
                    summary: summary,
                    commentState: viewModel.commentState,
                    replyStates: viewModel.replyStates,
                    currentUserID: viewModel.currentUserID,
                    newCommentBody: $viewModel.newCommentBody,
                    newCommentAudioData: $viewModel.newCommentAudioData,
                    newCommentAudioDuration: $viewModel.newCommentAudioDuration,
                    newCommentPageText: $viewModel.newCommentPageText,
                    replyDrafts: $viewModel.replyDrafts,
                    replyAudioData: $viewModel.replyAudioData,
                    replyAudioDurations: $viewModel.replyAudioDurations,
                    updateProgressAction: viewModel.updateReadingProgress,
                    createCommentAction: viewModel.createComment,
                    updateCommentAction: viewModel.updateComment,
                    deleteCommentAction: viewModel.deleteComment,
                    prepareReplyThreadAction: viewModel.prepareReplyThread,
                    createReplyAction: viewModel.createReply
                )
            }
        case .failed(let message):
            VStack(spacing: PollenSpacing.medium) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 32))
                    .foregroundStyle(.orange)

                Text(message)
                    .font(PollenTypography.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(PollenColors.textSecondary)

                PrimaryButton("Tentar novamente", systemImage: "arrow.clockwise") {
                    Task {
                        await viewModel.load()
                    }
                }
            }
            .padding(PollenSpacing.large)
        }
    }
}
