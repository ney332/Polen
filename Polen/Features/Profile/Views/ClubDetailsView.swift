import SwiftUI

struct ClubDetailsView: View {
    let summary: HomeClubSummary
    @Binding var bookSearchQuery: String
    let bookSearchState: BookSearchState
    let bookSearchResults: [Book]
    let bookShelf: [ClubBookShelfItem]
    let isLoadingBookShelf: Bool
    let shelfCommentStates: [String: CommentTimelineState]
    let isChangingBook: Bool
    let searchBooksAction: () async -> Void
    let selectBookAction: (Book) async -> Void
    let loadShelfAction: () async -> Void
    let loadBookCommentsAction: (ClubBookShelfItem) async -> Void
    let isLeavingClub: Bool
    let leaveClubAction: () async -> Void

    @State private var isShowingBookPicker = false

    private var invitationURL: URL {
        InviteLinkParser.makeInviteURL(inviteCode: summary.inviteCode)
    }

    private var invitationMessage: String {
        "Entre no meu clube de leitura \"\(summary.clubName)\" no Polen. Código: \(summary.inviteCode)"
    }

    var body: some View {
        List {
            Section("Clube") {
                Label(summary.clubName, systemImage: summary.photoAssetName ?? "person.2")
                Label("\(summary.memberCount) membro\(summary.memberCount == 1 ? "" : "s")", systemImage: "person.2.fill")
                Label(summary.inviteCode, systemImage: "number")
                ShareLink(
                    item: invitationURL,
                    subject: Text("Convite para \(summary.clubName)"),
                    message: Text(invitationMessage)
                ) {
                    Label("Convidar membros", systemImage: "square.and.arrow.up")
                }
            }

            Section("Livro atual") {
                if let activeBook = summary.activeBook {
                    ActiveBookView(book: activeBook)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                } else {
                    Label("Nenhum livro selecionado", systemImage: "book.closed")
                        .foregroundStyle(PollenColors.textSecondary)
                }

                Button {
                    isShowingBookPicker = true
                } label: {
                    Label(summary.activeBook == nil ? "Escolher livro" : "Trocar livro", systemImage: "arrow.triangle.2.circlepath")
                }
            }

            Section("Progresso") {
                ProfileReadingProgressView(summary: summary)
            }

            Section("Estante de livros") {
                if isLoadingBookShelf {
                    ProgressView()
                } else if bookShelf.isEmpty {
                    Label("Nenhum livro na estante", systemImage: "books.vertical")
                        .foregroundStyle(PollenColors.textSecondary)
                } else {
                    ForEach(bookShelf) { item in
                        NavigationLink {
                            ClubBookCommentsArchiveView(
                                item: item,
                                commentState: shelfCommentStates[item.id] ?? .loading,
                                loadAction: {
                                    await loadBookCommentsAction(item)
                                }
                            )
                        } label: {
                            ClubBookShelfRowView(item: item)
                        }
                    }
                }
            }

            Section {
                Button(role: .destructive) {
                    Task {
                        await leaveClubAction()
                    }
                } label: {
                    Label(isLeavingClub ? "Saindo..." : "Sair do clube", systemImage: "rectangle.portrait.and.arrow.right")
                }
                .disabled(isLeavingClub)
            }
        }
        .navigationTitle("Meu clube")
        .task {
            await loadShelfAction()
        }
        .sheet(isPresented: $isShowingBookPicker) {
            NavigationStack {
                ClubBookPickerSheetView(
                    query: $bookSearchQuery,
                    searchState: bookSearchState,
                    selectedBook: summary.activeBook,
                    results: bookSearchResults,
                    isSaving: isChangingBook,
                    searchAction: searchBooksAction,
                    selectAction: { book in
                        await selectBookAction(book)
                        isShowingBookPicker = false
                    }
                )
            }
            .presentationDetents([.large])
        }
    }
}

private struct ClubBookShelfRowView: View {
    let item: ClubBookShelfItem

    var body: some View {
        HStack(spacing: PollenSpacing.medium) {
            AsyncImage(url: item.book.coverURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    Image(systemName: "book.closed")
                        .foregroundStyle(PollenColors.primary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(PollenColors.groupedBackground)
                }
            }
            .frame(width: 44, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

            VStack(alignment: .leading, spacing: PollenSpacing.xSmall) {
                HStack(spacing: PollenSpacing.xSmall) {
                    Text(item.book.title)
                        .font(PollenTypography.body)
                        .foregroundStyle(PollenColors.textPrimary)
                        .lineLimit(2)

                    if item.isActive {
                        Text("Atual")
                            .font(PollenTypography.caption)
                            .foregroundStyle(PollenColors.primary)
                    }
                }

                if !item.book.authors.isEmpty {
                    Text(item.book.authors.joined(separator: ", "))
                        .font(PollenTypography.caption)
                        .foregroundStyle(PollenColors.textSecondary)
                        .lineLimit(1)
                }
            }
        }
    }
}

private struct ClubBookCommentsArchiveView: View {
    let item: ClubBookShelfItem
    let commentState: CommentTimelineState
    let loadAction: () async -> Void

    var body: some View {
        List {
            Section {
                ActiveBookView(book: item.book)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }

            Section("Comentarios") {
                commentsContent
            }
        }
        .navigationTitle(item.book.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadAction()
        }
    }

    @ViewBuilder
    private var commentsContent: some View {
        switch commentState {
        case .loading:
            ProgressView()
        case .empty:
            Label("Nenhum comentario neste livro", systemImage: "bubble.left")
                .foregroundStyle(PollenColors.textSecondary)
        case .failed(let message):
            Text(message)
                .font(PollenTypography.caption)
                .foregroundStyle(.red)
        case .loaded(let comments):
            ForEach(comments) { comment in
                ArchivedCommentRowView(comment: comment)
                    .listRowInsets(EdgeInsets(top: PollenSpacing.small, leading: 0, bottom: PollenSpacing.small, trailing: 0))
                    .listRowBackground(Color.clear)
            }
        }
    }
}

private struct ArchivedCommentRowView: View {
    let comment: Comment

    var body: some View {
        HStack(alignment: .top, spacing: PollenSpacing.small) {
            AuthorAvatarView(
                imageData: comment.authorAvatarImageData,
                symbolName: comment.authorAvatarAssetName,
                size: 40
            )

            VStack(alignment: .leading, spacing: PollenSpacing.xSmall) {
                HStack(alignment: .firstTextBaseline, spacing: PollenSpacing.xSmall) {
                    Text(comment.authorDisplayName ?? "Leitor")
                        .font(PollenTypography.headline)
                        .lineLimit(1)

                    Text("Pagina \(comment.pageReference)")
                        .font(PollenTypography.caption)
                        .foregroundStyle(PollenColors.textSecondary)
                }

                if !comment.body.isEmpty {
                    Text(comment.body)
                        .font(PollenTypography.body)
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
        .background(PollenColors.groupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct ClubBookPickerSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var query: String
    let searchState: BookSearchState
    let selectedBook: Book?
    let results: [Book]
    let isSaving: Bool
    let searchAction: () async -> Void
    let selectAction: (Book) async -> Void

    var body: some View {
        ClubBookSelectionStepView(
            query: $query,
            searchState: isSaving ? .loading : searchState,
            selectedBook: selectedBook,
            results: results,
            searchAction: searchAction,
            selectAction: { book in
                Task {
                    await selectAction(book)
                }
            }
        )
        .navigationTitle(selectedBook == nil ? "Escolher livro" : "Trocar livro")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Fechar") {
                    dismiss()
                }
            }
        }
    }
}
