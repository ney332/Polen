import SwiftUI

struct CreateClubView: View {
    @Bindable var viewModel: CreateClubViewModel

    var body: some View {
        VStack(spacing: 0) {
            CreateClubProgressView(
                stepTitle: viewModel.currentStep.title,
                progressText: viewModel.progressText
            )
            .padding(PollenSpacing.large)

            Divider()

            stepContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            footer
        }
        .navigationTitle("Criar Clube")
        .navigationBarTitleDisplayMode(.inline)
        .background(PollenColors.background)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case .name:
            ClubNameStepView(name: $viewModel.draft.name)
        case .photo:
            ClubPhotoStepView(selectedSymbolName: $viewModel.draft.photoSymbolName)
        case .book:
            ClubBookSelectionStepView(
                query: $viewModel.bookSearchQuery,
                searchState: viewModel.bookSearchState,
                selectedBook: viewModel.draft.selectedBook,
                results: viewModel.bookSearchResults,
                searchAction: viewModel.searchBooks,
                selectAction: viewModel.selectBook
            )
        case .invite:
            InviteMembersStepView(
                invitedMembers: viewModel.draft.invitedMembers,
                addInviteAction: viewModel.addInvite,
                removeInviteAction: viewModel.removeInvite
            )
        case .review:
            CreateClubReviewStepView(
                draft: viewModel.draft,
                invitePreview: viewModel.invitePreview
            )
        }
    }

    private var footer: some View {
        VStack(spacing: PollenSpacing.small) {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(PollenTypography.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: PollenSpacing.small) {
                if viewModel.canGoBack {
                    Button {
                        viewModel.goBack()
                    } label: {
                        Image(systemName: "chevron.left")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .accessibilityLabel("Voltar")
                }

                PrimaryButton(
                    viewModel.isSavingClub ? "Criando..." : (viewModel.isLastStep ? "Criar Clube" : "Continuar"),
                    systemImage: viewModel.isLastStep ? "checkmark" : "chevron.right"
                ) {
                    viewModel.continueFlow()
                }
                .disabled(viewModel.isSavingClub)
            }
        }
        .padding(PollenSpacing.large)
        .background(PollenColors.background)
    }
}
