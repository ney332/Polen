import SwiftUI

struct CommentComposerView: View {
    @Binding var bodyText: String
    @Binding var pageText: String
    let currentPage: Int
    let createAction: () async -> Void

    @State private var isCreating = false

    var body: some View {
        VStack(alignment: .leading, spacing: PollenSpacing.small) {
            Text("Novo comentário")
                .font(PollenTypography.headline)

            TextField("Página", text: $pageText)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 120)

            TextField("Escreva sobre este trecho", text: $bodyText, axis: .vertical)
                .lineLimit(3...5)
                .textFieldStyle(.roundedBorder)

            Button {
                Task {
                    isCreating = true
                    await createAction()
                    isCreating = false
                }
            } label: {
                Label(isCreating ? "Publicando" : "Publicar", systemImage: "text.bubble")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isCreating || bodyText.trimmed.isEmpty)
        }
        .onAppear {
            if pageText.isEmpty {
                pageText = "\(currentPage)"
            }
        }
    }
}
