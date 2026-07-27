import AuthenticationServices
import SwiftUI

struct SignInView: View {
    @Bindable var viewModel: SignInViewModel

    var body: some View {
        VStack(spacing: PollenSpacing.large) {
            Spacer()

            VStack(spacing: PollenSpacing.medium) {
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 52, weight: .semibold))
                    .foregroundStyle(PollenColors.primary)

                Text(AppConstants.appName)
                    .font(PollenTypography.title)

                Text("Leitura compartilhada, comentários no contexto certo e sem spoilers.")
                    .font(PollenTypography.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(PollenColors.textSecondary)
                    .padding(.horizontal, PollenSpacing.large)
            }

            Spacer()

            SignInWithAppleButton(.signIn) { request in
                viewModel.configure(request: request)
            } onCompletion: { result in
                Task {
                    await viewModel.handleAuthorization(result)
                }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .disabled(viewModel.isSigningIn)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(PollenTypography.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(PollenSpacing.large)
        .background(PollenColors.background)
    }
}

