import PhotosUI
import SwiftUI

struct ProfileEditorView: View {
    @Binding var displayName: String
    @Binding var biography: String
    let isSaving: Bool
    let saveAction: () async -> Void
    let photoAction: (PhotosPickerItem?) async -> Void
    let dismissAction: () -> Void

    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Form {
                Section("Foto") {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label("Escolher da galeria", systemImage: "photo")
                    }
                    .onChange(of: selectedPhotoItem) { _, item in
                        Task {
                            await photoAction(item)
                        }
                    }
                }

                Section("Informações") {
                    TextField("Nome", text: $displayName)
                        .textInputAutocapitalization(.words)

                    TextField("Biografia", text: $biography, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("Editar perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar", action: dismissAction)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isSaving ? "Salvando" : "Salvar") {
                        Task {
                            await saveAction()
                            dismissAction()
                        }
                    }
                    .disabled(isSaving || displayName.trimmed.isEmpty)
                }
            }
        }
    }
}
