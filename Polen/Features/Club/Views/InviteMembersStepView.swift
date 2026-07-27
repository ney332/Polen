import SwiftUI

struct InviteMembersStepView: View {
    let invitedMembers: [String]
    let addInviteAction: (String) -> Void
    let removeInviteAction: (IndexSet) -> Void

    @State private var inviteText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: PollenSpacing.medium) {
            Text("Convide membros")
                .font(PollenTypography.headline)

            HStack(spacing: PollenSpacing.small) {
                TextField("E-mail ou nome", text: $inviteText)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .padding(PollenSpacing.medium)
                    .background(PollenColors.groupedBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                Button {
                    addInviteAction(inviteText)
                    inviteText = ""
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityLabel("Adicionar convite")
            }

            if invitedMembers.isEmpty {
                ContentUnavailableView(
                    "Nenhum convite ainda",
                    systemImage: "person.2",
                    description: Text("Você também pode criar o clube agora e convidar membros depois.")
                )
            } else {
                List {
                    ForEach(invitedMembers, id: \.self) { member in
                        Label(member, systemImage: "envelope")
                    }
                    .onDelete(perform: removeInviteAction)
                }
                .listStyle(.plain)
            }
        }
        .padding(PollenSpacing.large)
    }
}
