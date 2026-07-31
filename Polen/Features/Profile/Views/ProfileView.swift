import PhotosUI
import SwiftUI

struct ProfileView: View {
    @Bindable var viewModel: ProfileViewModel
    @State private var isEditingProfile = false

    var body: some View {
        List {
            Section {
                ProfileHeaderView(
                    displayName: viewModel.displayName,
                    createdAtText: viewModel.createdAtText,
                    avatarName: viewModel.selectedAvatarName,
                    avatarImageData: viewModel.avatarImageData,
                    biography: viewModel.summary?.user.biography ?? viewModel.biographyDraft,
                    editAction: {
                        isEditingProfile = true
                    }
                )
            }

            Section("Meu clube") {
                if let clubSummary = viewModel.summary?.clubSummary {
                    NavigationLink {
                        ClubDetailsView(
                            summary: clubSummary,
                            bookSearchQuery: $viewModel.clubBookSearchQuery,
                            bookSearchState: viewModel.clubBookSearchState,
                            bookSearchResults: viewModel.clubBookSearchResults,
                            bookShelf: viewModel.clubBookShelf,
                            isLoadingBookShelf: viewModel.isLoadingBookShelf,
                            shelfCommentStates: viewModel.shelfCommentStates,
                            isChangingBook: viewModel.isChangingClubBook,
                            searchBooksAction: viewModel.searchClubBooks,
                            selectBookAction: viewModel.setClubBook,
                            loadShelfAction: viewModel.loadBookShelf,
                            loadBookCommentsAction: viewModel.loadComments,
                            isLeavingClub: viewModel.isLeavingClub,
                            leaveClubAction: viewModel.leaveClub
                        )
                    } label: {
                        ProfileClubSummaryView(summary: clubSummary)
                    }
                } else {
                    ProfileClubSummaryView(summary: viewModel.summary?.clubSummary)
                }
            }

            Section("Progresso da leitura") {
                ProfileReadingProgressView(summary: viewModel.summary?.clubSummary)
            }

            Section("Preferências") {
                Toggle("Notificações", isOn: $viewModel.notificationsEnabled)
                    .onChange(of: viewModel.notificationsEnabled) {
                        Task {
                            await viewModel.saveNotificationPreference()
                        }
                    }

                NavigationLink {
                    PrivacyPolicyView()
                } label: {
                    Label("Política e Privacidade", systemImage: "lock.shield")
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .font(PollenTypography.caption)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button("Sair da conta", role: .destructive) {
                    Task {
                        await viewModel.signOut()
                    }
                }
            }
        }
        .navigationTitle("Perfil")
        .task {
            await viewModel.load()
        }
        .sheet(isPresented: $isEditingProfile) {
            ProfileEditorView(
                displayName: $viewModel.displayNameDraft,
                biography: $viewModel.biographyDraft,
                isSaving: viewModel.isSavingProfile,
                saveAction: viewModel.saveProfile,
                photoAction: loadPhoto,
                dismissAction: {
                    isEditingProfile = false
                }
            )
        }
    }

    private func loadPhoto(_ item: PhotosPickerItem?) async {
        guard let data = try? await item?.loadTransferable(type: Data.self) else {
            return
        }

        await viewModel.updateAvatarImageData(data)
    }
}
