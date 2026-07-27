import SwiftUI

struct ClubBookSelectionStepView: View {
    @Binding var query: String

    let searchState: BookSearchState
    let selectedBook: Book?
    let results: [Book]
    let searchAction: () async -> Void
    let selectAction: (Book) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: PollenSpacing.medium) {
            Text("Selecione o livro ativo")
                .font(PollenTypography.headline)

            HStack(spacing: PollenSpacing.small) {
                TextField("Buscar por título, autor ou ISBN", text: $query)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.search)
                    .padding(PollenSpacing.medium)
                    .background(PollenColors.groupedBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .onSubmit {
                        Task {
                            await searchAction()
                        }
                    }

                Button {
                    Task {
                        await searchAction()
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityLabel("Buscar livro")
            }

            content
        }
        .padding(PollenSpacing.large)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    private var content: some View {
        switch searchState {
        case .idle:
            ContentUnavailableView(
                "Busque um livro",
                systemImage: "book.closed",
                description: Text("Pesquise na Google Books API e selecione o livro ativo do clube.")
            )
        case .loading:
            VStack(spacing: PollenSpacing.medium) {
                ProgressView()
                Text("Buscando livros")
                    .font(PollenTypography.body)
                    .foregroundStyle(PollenColors.textSecondary)
            }
            .frame(maxWidth: .infinity, minHeight: 180)
        case .empty:
            ContentUnavailableView(
                "Nenhum livro encontrado",
                systemImage: "magnifyingglass",
                description: Text("Tente buscar por outro título, autor ou ISBN.")
            )
        case .failed(let message):
            ContentUnavailableView(
                "Não foi possível buscar",
                systemImage: "exclamationmark.triangle",
                description: Text(message)
            )
        case .loaded:
            ScrollView {
                LazyVStack(spacing: PollenSpacing.small) {
                    ForEach(results) { book in
                        GoogleBookResultRow(
                            book: book,
                            isSelected: selectedBook == book
                        ) {
                            selectAction(book)
                        }
                    }
                }
                .padding(.bottom, PollenSpacing.large)
            }
        }
    }
}
