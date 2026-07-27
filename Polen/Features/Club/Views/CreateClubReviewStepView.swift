import SwiftUI

struct CreateClubReviewStepView: View {
    let draft: CreateClubDraft
    let invitePreview: String

    var body: some View {
        List {
            Section {
                HStack(spacing: PollenSpacing.medium) {
                    Image(systemName: draft.photoSymbolName)
                        .font(.title)
                        .foregroundStyle(PollenColors.primary)

                    VStack(alignment: .leading, spacing: PollenSpacing.xSmall) {
                        Text(draft.name)
                            .font(PollenTypography.headline)

                        Text("Código \(invitePreview)")
                            .font(PollenTypography.caption)
                            .foregroundStyle(PollenColors.textSecondary)
                    }
                }
                .padding(.vertical, PollenSpacing.small)
            }

            Section("Livro") {
                VStack(alignment: .leading, spacing: PollenSpacing.xSmall) {
                    Label(draft.selectedBook?.title ?? "Não selecionado", systemImage: "book")

                    if let authors = draft.selectedBook?.authors, !authors.isEmpty {
                        Text(authors.joined(separator: ", "))
                            .font(PollenTypography.caption)
                            .foregroundStyle(PollenColors.textSecondary)
                    }
                }
            }

            Section("Convites") {
                if draft.invitedMembers.isEmpty {
                    Text("Nenhum convite adicionado")
                        .foregroundStyle(PollenColors.textSecondary)
                } else {
                    ForEach(draft.invitedMembers, id: \.self) { member in
                        Label(member, systemImage: "envelope")
                    }
                }
            }
        }
    }
}
