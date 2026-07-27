import SwiftUI

struct GoogleBookResultRow: View {
    let book: Book
    let isSelected: Bool
    let selectAction: () -> Void

    var body: some View {
        Button(action: selectAction) {
            HStack(alignment: .top, spacing: PollenSpacing.medium) {
                AsyncImage(url: book.coverURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure, .empty:
                        Image(systemName: "book.closed.fill")
                            .font(.title2)
                            .foregroundStyle(PollenColors.primary)
                    @unknown default:
                        Image(systemName: "book.closed.fill")
                            .font(.title2)
                            .foregroundStyle(PollenColors.primary)
                    }
                }
                .frame(width: 52, height: 76)
                .background(PollenColors.groupedBackground)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

                VStack(alignment: .leading, spacing: PollenSpacing.xSmall) {
                    Text(book.title)
                        .font(PollenTypography.headline)
                        .foregroundStyle(PollenColors.textPrimary)
                        .lineLimit(2)

                    Text(book.authors.isEmpty ? "Autor desconhecido" : book.authors.joined(separator: ", "))
                        .font(PollenTypography.caption)
                        .foregroundStyle(PollenColors.textSecondary)
                        .lineLimit(2)

                    if let pageCount = book.pageCount {
                        Text("\(pageCount) páginas")
                            .font(PollenTypography.caption)
                            .foregroundStyle(PollenColors.textSecondary)
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(PollenColors.primary)
                }
            }
            .padding(PollenSpacing.medium)
            .background(PollenColors.groupedBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
