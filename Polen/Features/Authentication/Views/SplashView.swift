import SwiftUI

struct SplashView: View {
    var body: some View {
        VStack(spacing: PollenSpacing.medium) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 56, weight: .semibold))
                .foregroundStyle(PollenColors.primary)

            Text(AppConstants.appName)
                .font(PollenTypography.title)
                .foregroundStyle(PollenColors.textPrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PollenColors.background)
    }
}

#Preview {
    SplashView()
}
