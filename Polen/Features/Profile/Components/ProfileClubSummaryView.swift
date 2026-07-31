import SwiftUI

struct ProfileClubSummaryView: View {
    let summary: HomeClubSummary?

    var body: some View {
        if let summary {
            VStack(alignment: .leading, spacing: PollenSpacing.small) {
                Label(summary.clubName, systemImage: summary.photoAssetName ?? "person.2")
                    .font(PollenTypography.headline)

                Text(summary.activeBook?.title ?? "Nenhum livro selecionado")
                    .font(PollenTypography.body)
                    .foregroundStyle(PollenColors.textSecondary)

                Label("\(summary.memberCount) membro\(summary.memberCount == 1 ? "" : "s")", systemImage: "person.2.fill")
                    .font(PollenTypography.caption)
                    .foregroundStyle(PollenColors.textSecondary)
            }
        } else {
            Label("Você ainda não participa de um clube", systemImage: "person.2.slash")
                .foregroundStyle(PollenColors.textSecondary)
        }
    }
}

extension ProfileClubSummaryView {
    init(summary: HomeClubSummary) {
        self.summary = summary
    }
}
