import SwiftUI

struct CommentTimelineRowView: View {
    let comment: Comment
    let canEdit: Bool
    let replyState: ReplyThreadState
    @Binding var replyDraft: String
    let updateAction: (String) async -> Void
    let deleteAction: () async -> Void
    let toggleRepliesAction: () async -> Void
    let createReplyAction: () async -> Void

    @State private var isEditing = false
    @State private var draftBody = ""
    @State private var isSaving = false
    @State private var isDeleting = false

    var body: some View {
        VStack(alignment: .leading, spacing: PollenSpacing.small) {
            HStack {
                Label("Página \(comment.pageReference)", systemImage: "bookmark")
                    .font(PollenTypography.caption)
                    .foregroundStyle(PollenColors.primary)

                Spacer()

                Text(comment.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(PollenTypography.caption)
                    .foregroundStyle(PollenColors.textSecondary)
            }

            if isEditing {
                TextField("Comentário", text: $draftBody, axis: .vertical)
                    .lineLimit(2...5)
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Button("Cancelar") {
                        isEditing = false
                        draftBody = comment.body
                    }
                    .buttonStyle(.bordered)

                    Button(isSaving ? "Salvando" : "Salvar") {
                        Task {
                            isSaving = true
                            await updateAction(draftBody)
                            isSaving = false
                            isEditing = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isSaving || draftBody.trimmed.isEmpty)
                }
            } else {
                Text(comment.body)
                    .font(PollenTypography.body)
                    .foregroundStyle(PollenColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if canEdit && !isEditing {
                HStack {
                    Button {
                        draftBody = comment.body
                        isEditing = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Editar comentário")

                    Button(role: .destructive) {
                        Task {
                            isDeleting = true
                            await deleteAction()
                            isDeleting = false
                        }
                    } label: {
                        Image(systemName: isDeleting ? "hourglass" : "trash")
                    }
                    .buttonStyle(.bordered)
                    .disabled(isDeleting)
                    .accessibilityLabel("Excluir comentário")
                }
            }

            Divider()

            Button {
                Task {
                    await toggleRepliesAction()
                }
            } label: {
                Label(threadButtonTitle, systemImage: "bubble.left.and.bubble.right")
            }
            .font(PollenTypography.caption)
            .buttonStyle(.plain)

            replyThread
        }
        .padding(PollenSpacing.medium)
        .background(PollenColors.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    @ViewBuilder
    private var replyThread: some View {
        switch replyState {
        case .collapsed:
            EmptyView()
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity)
        case .empty:
            VStack(alignment: .leading, spacing: PollenSpacing.small) {
                Text("Nenhuma resposta ainda.")
                    .font(PollenTypography.caption)
                    .foregroundStyle(PollenColors.textSecondary)

                ReplyComposerView(
                    bodyText: $replyDraft,
                    createAction: createReplyAction
                )
            }
        case .failed(let message):
            Text(message)
                .font(PollenTypography.caption)
                .foregroundStyle(.red)
        case .loaded(let replies):
            VStack(alignment: .leading, spacing: PollenSpacing.small) {
                ForEach(replies) { reply in
                    ReplyRowView(reply: reply)
                }

                ReplyComposerView(
                    bodyText: $replyDraft,
                    createAction: createReplyAction
                )
            }
        }
    }

    private var threadButtonTitle: String {
        switch replyState {
        case .collapsed:
            "Ver discussão"
        case .loading:
            "Carregando discussão"
        case .loaded, .empty, .failed:
            "Ocultar discussão"
        }
    }
}
