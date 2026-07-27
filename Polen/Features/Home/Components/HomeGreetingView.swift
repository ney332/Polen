import SwiftUI

struct HomeGreetingView: View {
    let displayName: String

    var body: some View {
        VStack(alignment: .leading, spacing: PollenSpacing.xSmall) {
            Text("Olá, \(displayName)")
                .font(PollenTypography.headline)
                .foregroundStyle(PollenColors.textPrimary)

            Text(AppConstants.appName)
                .font(PollenTypography.caption)
                .foregroundStyle(PollenColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
