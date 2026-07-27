import SwiftUI

struct ClubMembersPreviewView: View {
    let memberCount: Int
    let inviteCode: String

    var body: some View {
        VStack(alignment: .leading, spacing: PollenSpacing.small) {
            HStack {
                Text("Membros")
                    .font(PollenTypography.headline)

                Spacer()

                Text("\(memberCount)")
                    .font(PollenTypography.caption)
                    .foregroundStyle(PollenColors.textSecondary)
            }

            HStack(spacing: PollenSpacing.small) {
                ForEach(0..<max(min(memberCount, 4), 1), id: \.self) { index in
                    Image(systemName: "person.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(PollenColors.primary)
                        .frame(width: 36, height: 36)
                        .background(PollenColors.background)
                        .clipShape(Circle())
                        .accessibilityLabel("Membro \(index + 1)")
                }

                Spacer()
            }

            Label(inviteCode, systemImage: "number")
                .font(PollenTypography.caption)
                .foregroundStyle(PollenColors.textSecondary)
        }
        .padding(PollenSpacing.medium)
        .background(PollenColors.groupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
