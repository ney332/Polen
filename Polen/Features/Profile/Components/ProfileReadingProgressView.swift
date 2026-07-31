import SwiftUI

struct ProfileReadingProgressView: View {
    let summary: HomeClubSummary?

    var body: some View {
        if let summary, let readingProgress = summary.readingProgress {
            VStack(alignment: .leading, spacing: PollenSpacing.small) {
                HStack {
                    Label("Página \(readingProgress.currentPage)", systemImage: "bookmark")
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
        guard let pageCount = summary.activeBook?.pageCount, pageCount > 0 else {
            return "Livro sem total de páginas"
        }

        return "\(summary.readingProgress?.currentPage ?? 0)/\(pageCount)"
    }

    private func progressFraction(for summary: HomeClubSummary) -> Double {
        guard let pageCount = summary.activeBook?.pageCount,
              let readingProgress = summary.readingProgress,
              pageCount > 0 else {
            return 0
        }

        return min(Double(readingProgress.currentPage) / Double(pageCount), 1)
    }
}

extension ProfileReadingProgressView {
    init(summary: HomeClubSummary) {
        self.summary = summary
    }
}
