import SwiftUI

struct ClubDetailsView: View {
    let summary: HomeClubSummary
    let isLeavingClub: Bool
    let leaveClubAction: () async -> Void

    private var invitationURL: URL {
        InviteLinkParser.makeInviteURL(inviteCode: summary.inviteCode)
    }

    private var invitationMessage: String {
        "Entre no meu clube de leitura \"\(summary.clubName)\" no Polen. Código: \(summary.inviteCode)"
    }

    var body: some View {
        List {
            Section("Clube") {
                Label(summary.clubName, systemImage: summary.photoAssetName ?? "person.2")
                Label("\(summary.memberCount) membro\(summary.memberCount == 1 ? "" : "s")", systemImage: "person.2.fill")
                Label(summary.inviteCode, systemImage: "number")
                ShareLink(
                    item: invitationURL,
                    subject: Text("Convite para \(summary.clubName)"),
                    message: Text(invitationMessage)
                ) {
                    Label("Convidar membros", systemImage: "square.and.arrow.up")
                }
            }

            Section("Livro atual") {
                ActiveBookView(book: summary.activeBook)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }

            Section("Progresso") {
                ProfileReadingProgressView(summary: summary)
            }

            Section {
                Button(role: .destructive) {
                    Task {
                        await leaveClubAction()
                    }
                } label: {
                    Label(isLeavingClub ? "Saindo..." : "Sair do clube", systemImage: "rectangle.portrait.and.arrow.right")
                }
                .disabled(isLeavingClub)
            }
        }
        .navigationTitle("Meu clube")
    }
}
