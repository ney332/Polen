import SwiftUI

struct EmptyHomeView: View {
    let createAction: () -> Void
    let joinAction: () -> Void

    var body: some View {
        VStack(spacing: PollenSpacing.large) {
            Spacer()

            VStack(spacing: PollenSpacing.medium) {
                Image(systemName: "books.vertical")
                    .font(.system(size: 60, weight: .regular))
                    .foregroundStyle(PollenColors.primary)

                VStack(spacing: PollenSpacing.small) {
                    Text("Você ainda não possui um clube.")
                        .font(PollenTypography.headline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(PollenColors.textPrimary)

                    Text("Comece criando um clube ou entre em um convite existente.")
                        .font(PollenTypography.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(PollenColors.textSecondary)
                }
            }

            VStack(spacing: PollenSpacing.small) {
                PrimaryButton("Criar Clube", systemImage: "plus") {
                    createAction()
                }

                Button {
                    joinAction()
                } label: {
                    Label("Entrar em um Clube", systemImage: "person.2.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }

            Spacer()
        }
        .padding(PollenSpacing.large)
        .background(PollenColors.background)
    }
}
