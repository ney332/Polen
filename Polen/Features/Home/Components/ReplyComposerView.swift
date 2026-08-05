import SwiftUI

struct ReplyComposerView: View {
    @Binding var bodyText: String
    @Binding var audioData: Data?
    @Binding var audioDuration: TimeInterval?
    let createAction: () async -> Void

    @State private var isCreating = false

    var body: some View {
        HStack(alignment: .top, spacing: PollenSpacing.small) {
            TextField("Responder", text: $bodyText, axis: .vertical)
                .lineLimit(1...4)
                .textFieldStyle(.roundedBorder)

            AudioRecorderView(audioData: $audioData, audioDuration: $audioDuration)

            Button {
                Task {
                    isCreating = true
                    await createAction()
                    isCreating = false
                }
            } label: {
                Image(systemName: isCreating ? "hourglass" : "arrow.up.circle.fill")
                    .font(.title3)
            }
            .buttonStyle(.plain)
            .disabled(isCreating || (bodyText.trimmed.isEmpty && audioData == nil))
            .accessibilityLabel("Enviar resposta")
        }
    }
}
