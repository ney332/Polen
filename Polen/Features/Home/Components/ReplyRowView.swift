import SwiftUI

struct ReplyRowView: View {
    let reply: Reply

    var body: some View {
        VStack(alignment: .leading, spacing: PollenSpacing.xSmall) {
            Text(reply.body)
                .font(PollenTypography.body)
                .foregroundStyle(PollenColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(reply.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(PollenTypography.caption)
                .foregroundStyle(PollenColors.textSecondary)
        }
        .padding(PollenSpacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PollenColors.groupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
