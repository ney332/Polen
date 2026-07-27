import SwiftUI

struct JoinClubView: View {
    @Bindable var viewModel: JoinClubViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: PollenSpacing.large) {
            VStack(alignment: .leading, spacing: PollenSpacing.small) {
                Text("Entre em um clube")
                    .font(PollenTypography.headline)

                Text("Use o código enviado por um membro do clube.")
                    .font(PollenTypography.body)
                    .foregroundStyle(PollenColors.textSecondary)
            }

            TextField("Código do clube", text: $viewModel.inviteCode)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .padding(PollenSpacing.medium)
                .background(PollenColors.groupedBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(PollenTypography.caption)
                    .foregroundStyle(.red)
            }

            PrimaryButton(viewModel.isJoining ? "Entrando..." : "Entrar", systemImage: "arrow.right") {
                viewModel.joinClub()
            }
            .disabled(viewModel.isJoining)

            Spacer()
        }
        .padding(PollenSpacing.large)
        .navigationTitle("Entrar em Clube")
        .navigationBarTitleDisplayMode(.inline)
        .background(PollenColors.background)
    }
}
