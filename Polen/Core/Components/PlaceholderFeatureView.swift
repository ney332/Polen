import SwiftUI

struct PlaceholderFeatureView: View {
    let title: String

    var body: some View {
        VStack(spacing: PollenSpacing.medium) {
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(PollenColors.primary)

            Text(title)
                .font(PollenTypography.headline)
                .foregroundStyle(PollenColors.textPrimary)

            Text("Fluxo reservado para a Sprint 4.")
                .font(PollenTypography.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(PollenColors.textSecondary)
        }
        .padding(PollenSpacing.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PollenColors.background)
        .navigationTitle(title)
    }
}
