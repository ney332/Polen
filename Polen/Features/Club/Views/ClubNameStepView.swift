import SwiftUI

struct ClubNameStepView: View {
    @Binding var name: String

    var body: some View {
        VStack(alignment: .leading, spacing: PollenSpacing.medium) {
            Text("Como seu clube vai se chamar?")
                .font(PollenTypography.headline)

            TextField("Nome do clube", text: $name)
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
                .padding(PollenSpacing.medium)
                .background(PollenColors.groupedBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .padding(PollenSpacing.large)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}
