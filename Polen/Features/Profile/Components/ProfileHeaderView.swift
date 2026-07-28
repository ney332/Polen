import SwiftUI
import UIKit

struct ProfileHeaderView: View {
    let displayName: String
    let createdAtText: String
    let avatarName: String
    let avatarImageData: Data?
    let biography: String?
    let editAction: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: PollenSpacing.medium) {
            ZStack(alignment: .bottomTrailing) {
                avatarView

                Button(action: editAction) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(PollenColors.primary)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(PollenColors.background, lineWidth: 3)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Editar perfil")
            }

            VStack(spacing: PollenSpacing.xSmall) {
                Text(displayName)
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)

                if let biography, !biography.trimmed.isEmpty {
                    Text(biography)
                        .font(PollenTypography.body)
                        .foregroundStyle(PollenColors.textPrimary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text(createdAtText)
                    .font(PollenTypography.caption)
                    .foregroundStyle(PollenColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, PollenSpacing.small)
    }

    @ViewBuilder
    private var avatarView: some View {
        if let avatarImageData,
           let image = UIImage(data: avatarImageData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 112, height: 112)
                .clipShape(Circle())
        } else {
            Image(systemName: avatarName)
                .font(.system(size: 72))
                .foregroundStyle(PollenColors.primary)
                .frame(width: 112, height: 112)
                .background(PollenColors.groupedBackground)
                .clipShape(Circle())
        }
    }
}
