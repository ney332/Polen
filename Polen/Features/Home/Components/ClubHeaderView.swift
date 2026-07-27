import SwiftUI

struct ClubHeaderView: View {
    let summary: HomeClubSummary

    var body: some View {
        HStack(spacing: PollenSpacing.medium) {
            Image(systemName: summary.photoAssetName ?? "book.pages")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(PollenColors.primary)
                .frame(width: 56, height: 56)
                .background(PollenColors.groupedBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: PollenSpacing.xSmall) {
                Text(summary.clubName)
                    .font(PollenTypography.title)
                    .lineLimit(2)

                Text("\(summary.memberCount) membro\(summary.memberCount == 1 ? "" : "s")")
                    .font(PollenTypography.caption)
                    .foregroundStyle(PollenColors.textSecondary)
            }

            Spacer()
        }
    }
}
