import SwiftUI

struct ProfileAvatarPickerView: View {
    @Binding var selectedAvatarName: String
    let chooseAction: (String) -> Void

    private let avatarNames = [
        "person.crop.circle.fill",
        "book.circle.fill",
        "leaf.circle.fill",
        "sparkles",
        "graduationcap.circle.fill"
    ]

    var body: some View {
        HStack(spacing: PollenSpacing.small) {
            ForEach(avatarNames, id: \.self) { avatarName in
                Button {
                    selectedAvatarName = avatarName
                    chooseAction(avatarName)
                } label: {
                    Image(systemName: avatarName)
                        .font(.title2)
                        .foregroundStyle(selectedAvatarName == avatarName ? .white : PollenColors.primary)
                        .frame(width: 44, height: 44)
                        .background(selectedAvatarName == avatarName ? PollenColors.primary : PollenColors.groupedBackground)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Selecionar avatar")
            }
        }
        .padding(.vertical, PollenSpacing.xSmall)
    }
}
