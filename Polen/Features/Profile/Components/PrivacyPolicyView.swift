import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        List {
            Section("Dados") {
                Text("O Pólen usa sua conta Apple para autenticação e armazena dados do clube no iCloud/CloudKit.")
                Text("Comentários e respostas ficam vinculados ao clube para manter o contexto da leitura.")
            }

            Section("Privacidade") {
                Text("O app não é uma rede social pública. As discussões pertencem ao clube.")
                Text("O progresso de leitura é usado para reduzir spoilers dentro da experiência do livro.")
            }
        }
        .navigationTitle("Privacidade")
    }
}
