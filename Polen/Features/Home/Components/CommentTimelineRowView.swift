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
        HStack(alignment: .top, spacing: PollenSpacing.small) {
            AuthorAvatarView(
                imageData: comment.authorAvatarImageData,
                symbolName: comment.authorAvatarAssetName,
                size: 44
            )

            VStack(alignment: .leading, spacing: PollenSpacing.small) {
                HStack(alignment: .firstTextBaseline, spacing: PollenSpacing.xSmall) {
                    Text(comment.authorDisplayName ?? "Leitor")
                        .font(PollenTypography.headline)
                        .foregroundStyle(PollenColors.textPrimary)
                        .lineLimit(1)

                    Text("Pagina \(comment.pageReference)")
                        .font(PollenTypography.caption)
                        .foregroundStyle(PollenColors.textSecondary)

                    Spacer(minLength: 0)
                }

                Text(comment.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(PollenTypography.caption)
                    .foregroundStyle(PollenColors.textSecondary)

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
                        .disabled(isSaving || (draftBody.trimmed.isEmpty && comment.audioData == nil))
                    }
                } else {
                    ZStack {
                        VStack(alignment: .leading, spacing: PollenSpacing.small) {
                            if !comment.body.isEmpty {
                                Text(comment.body)
                                    .font(PollenTypography.body)
                                    .foregroundStyle(PollenColors.textPrimary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            if let audioData = comment.audioData {
                                AudioPlaybackView(audioData: audioData, duration: comment.audioDuration)
                            }
                        }
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

                HStack(spacing: PollenSpacing.medium) {
                    Button {
                        replyAction()
                    } label: {
                        Label("Responder", systemImage: "bubble.left")
                    }
                    .disabled(isSpoilerLocked)
                    .opacity(isSpoilerLocked ? 0.55 : 1)

                    if canEdit && !isEditing && !isSpoilerLocked {
                        Button {
                            draftBody = comment.body
                            isEditing = true
                        } label: {
                            Image(systemName: "pencil")
                        }
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
                        .disabled(isDeleting)
                        .accessibilityLabel("Excluir comentário")
                    }
                }
                .font(PollenTypography.caption)
                .buttonStyle(.plain)
            }
        }
        .padding(PollenSpacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PollenColors.groupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
