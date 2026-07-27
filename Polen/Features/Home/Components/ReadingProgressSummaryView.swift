import SwiftUI

struct ReadingProgressSummaryView: View {
    let progress: ReadingProgress
    let pageCount: Int?
    let updateAction: (Int) async -> Void

    @State private var pageText: String
    @State private var isSaving = false

    init(
        progress: ReadingProgress,
        pageCount: Int?,
        updateAction: @escaping (Int) async -> Void
    ) {
        self.progress = progress
        self.pageCount = pageCount
        self.updateAction = updateAction
        _pageText = State(initialValue: "\(progress.currentPage)")
    }

    private var fraction: Double {
        guard let pageCount, pageCount > 0 else {
            return 0
        }

        return min(Double(progress.currentPage) / Double(pageCount), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: PollenSpacing.medium) {
            HStack {
                Text("Seu progresso")
                    .font(PollenTypography.headline)

                Spacer()

                Text(progressText)
                    .font(PollenTypography.caption)
                    .foregroundStyle(PollenColors.textSecondary)
            }

            ProgressView(value: fraction)
                .tint(PollenColors.primary)

            HStack(spacing: PollenSpacing.small) {
                Button {
                    stepPage(by: -1)
                } label: {
                    Image(systemName: "minus")
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.bordered)
                .disabled(currentPageValue <= 0 || isSaving)
                .accessibilityLabel("Diminuir página")

                TextField("Página", text: $pageText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 96)

                Button {
                    stepPage(by: 1)
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.bordered)
                .disabled(isAtLastPage || isSaving)
                .accessibilityLabel("Aumentar página")

                Spacer()

                Button {
                    Task {
                        await save()
                    }
                } label: {
                    Label(isSaving ? "Salvando" : "Salvar", systemImage: "icloud.and.arrow.up")
                }
                .buttonStyle(.borderedProminent)
                .disabled(isSaving || currentPageValue == progress.currentPage)
            }

            Text("Atualizado em \(progress.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                .font(PollenTypography.caption)
                .foregroundStyle(PollenColors.textSecondary)
        }
        .onChange(of: progress.currentPage) { _, newValue in
            pageText = "\(newValue)"
        }
        .padding(PollenSpacing.medium)
        .background(PollenColors.groupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var progressText: String {
        guard let pageCount, pageCount > 0 else {
            return "Página \(progress.currentPage)"
        }

        return "\(progress.currentPage)/\(pageCount)"
    }

    private var currentPageValue: Int {
        Int(pageText) ?? progress.currentPage
    }

    private var isAtLastPage: Bool {
        guard let pageCount, pageCount > 0 else {
            return false
        }

        return currentPageValue >= pageCount
    }

    private func stepPage(by delta: Int) {
        let upperBound = pageCount ?? Int.max
        let nextPage = min(max(currentPageValue + delta, 0), upperBound)
        pageText = "\(nextPage)"
    }

    private func save() async {
        let upperBound = pageCount ?? Int.max
        let nextPage = min(max(currentPageValue, 0), upperBound)
        pageText = "\(nextPage)"
        isSaving = true
        await updateAction(nextPage)
        isSaving = false
    }
}
