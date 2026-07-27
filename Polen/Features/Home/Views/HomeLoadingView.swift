import SwiftUI

struct HomeLoadingView: View {
    var body: some View {
        VStack(spacing: PollenSpacing.medium) {
            ProgressView()
                .controlSize(.large)

            Text("Preparando sua leitura")
                .font(PollenTypography.body)
                .foregroundStyle(PollenColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PollenColors.background)
    }
}
