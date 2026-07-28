import SwiftUI

struct ProfileReadingProgressView: View {
    let summary: HomeClubSummary?

    var body: some View {
        if let summary {
            VStack(alignment: .leading, spacing: PollenSpacing.small) {
                HStack {
                    Label("Página \(summary.readingProgress.currentPage)", systemImage: "bookmark")
                        .font(PollenTypography.headline)

                    Spacer()

                    Text(progressText(for: summary))
                        .font(PollenTypography.caption)
                        .foregroundStyle(PollenColors.textSecondary)
                }

                ProgressView(value: progressFraction(for: summary))
                    .tint(PollenColors.primary)
            }
        } else {
            Label("Sem progresso de leitura", systemImage: "bookmark.slash")
                .foregroundStyle(PollenColors.textSecondary)
        }
    }

    private func progressText(for summary: HomeClubSummary) -> String {
        guard let pageCount = summary.activeBook.pageCount, pageCount > 0 else {
            return "Livro sem total de páginas"
        }

        return "\(summary.readingProgress.currentPage)/\(pageCount)"
    }

    private func progressFraction(for summary: HomeClubSummary) -> Double {
        guard let pageCount = summary.activeBook.pageCount, pageCount > 0 else {
            return 0
        }

        return min(Double(summary.readingProgress.currentPage) / Double(pageCount), 1)
    }
}

extension ProfileReadingProgressView {
    init(summary: HomeClubSummary) {
        self.summary = summary
    }
}
