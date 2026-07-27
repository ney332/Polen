import SwiftUI

struct CreateClubProgressView: View {
    let stepTitle: String
    let progressText: String

    var body: some View {
        VStack(alignment: .leading, spacing: PollenSpacing.small) {
            Text(stepTitle)
                .font(PollenTypography.headline)
                .foregroundStyle(PollenColors.textPrimary)

            Text(progressText)
                .font(PollenTypography.caption)
                .foregroundStyle(PollenColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
