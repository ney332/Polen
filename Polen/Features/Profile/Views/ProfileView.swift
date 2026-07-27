import SwiftUI

struct ProfileView: View {
    @Bindable var viewModel: ProfileViewModel

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: PollenSpacing.small) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(PollenColors.primary)

                    Text(viewModel.displayName)
                        .font(PollenTypography.headline)
                }
                .padding(.vertical, PollenSpacing.small)
            }

            Section {
                Toggle("Notificações", isOn: $viewModel.notificationsEnabled)
                Label("Meu clube", systemImage: "person.2")
                Label("Progresso da leitura", systemImage: "bookmark")
                Label("Política e Privacidade", systemImage: "lock.shield")
            }

            Section {
                Button("Sair da conta", role: .destructive) {
                    Task {
                        await viewModel.signOut()
                    }
                }
            }
        }
        .navigationTitle("Perfil")
    }
}
