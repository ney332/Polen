import SwiftUI

struct ActiveBookView: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: PollenSpacing.medium) {
            Text("Livro ativo")
                .font(PollenTypography.headline)

            HStack(alignment: .top, spacing: PollenSpacing.medium) {
                AsyncImage(url: book.coverURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Image(systemName: "book.closed")
                            .font(.system(size: 28))
                            .foregroundStyle(PollenColors.primary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(PollenColors.groupedBackground)
                    }
                }
                .frame(width: 72, height: 108)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: PollenSpacing.small) {
                    Text(book.title)
                        .font(PollenTypography.headline)
                        .lineLimit(3)

                    if !book.authors.isEmpty {
                        Text(book.authors.joined(separator: ", "))
                            .font(PollenTypography.body)
                            .foregroundStyle(PollenColors.textSecondary)
                            .lineLimit(2)
                    }

                    if let pageCount = book.pageCount {
                        Label("\(pageCount) páginas", systemImage: "text.page")
                            .font(PollenTypography.caption)
                            .foregroundStyle(PollenColors.textSecondary)
                    }
                }

                Spacer(minLength: 0)
            }
        }
        .padding(PollenSpacing.medium)
        .background(PollenColors.groupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
