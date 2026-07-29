import SwiftUI

struct CommentTimelineRowView: View {
    let comment: Comment
    let canEdit: Bool
    let isSpoilerLocked: Bool
    let updateAction: (String) async -> Void
    let deleteAction: () async -> Void
    let replyAction: () -> Void

    @State private var isEditing = false
    @State private var draftBody = ""
    @State private var isSaving = false
    @State private var isDeleting = false

    var body: some View {
        VStack(alignment: .leading, spacing: PollenSpacing.small) {
            HStack(alignment: .top) {
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
                ZStack {
                    Text(comment.body)
                        .font(PollenTypography.body)
                        .foregroundStyle(PollenColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .blur(radius: isSpoilerLocked ? 6 : 0)
                        .opacity(isSpoilerLocked ? 0.55 : 1)

                    if isSpoilerLocked {
                        HStack(spacing: PollenSpacing.xSmall) {
                            Image(systemName: "eye.slash")

                            Text("Pode conter spoiler")
                        }
                        .font(PollenTypography.caption)
                        .foregroundStyle(PollenColors.textPrimary)
                        .padding(.horizontal, PollenSpacing.small)
                        .padding(.vertical, PollenSpacing.xSmall)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
            }

            if canEdit && !isEditing && !isSpoilerLocked {
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

            Button {
                replyAction()
            } label: {
                Label("Responder", systemImage: "bubble.left.and.bubble.right")
            }
            .font(PollenTypography.caption)
            .buttonStyle(.plain)
            .disabled(isSpoilerLocked)
            .opacity(isSpoilerLocked ? 0.55 : 1)
        }
        .padding(PollenSpacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PollenColors.groupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
