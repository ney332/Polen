import SwiftUI

struct ClubPhotoStepView: View {
    @Binding var selectedSymbolName: String

    private let symbols = [
        "person.3.fill",
        "books.vertical.fill",
        "leaf.fill",
        "bookmark.fill"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: PollenSpacing.medium) {
            Text("Escolha uma identidade visual")
                .font(PollenTypography.headline)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: PollenSpacing.small), count: 2), spacing: PollenSpacing.small) {
                ForEach(symbols, id: \.self) { symbol in
                    Button {
                        selectedSymbolName = symbol
                    } label: {
                        Image(systemName: symbol)
                            .font(.system(size: 34, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 96)
                    }
                    .buttonStyle(.bordered)
                    .tint(selectedSymbolName == symbol ? PollenColors.primary : PollenColors.textSecondary)
                    .accessibilityLabel("Selecionar foto do clube")
                }
            }
        }
        .padding(PollenSpacing.large)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}
