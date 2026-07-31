import SwiftUI

struct ClubActionSheetView: View {
    let summary: HomeClubSummary
    @Binding var newCommentBody: String
    @Binding var newCommentPageText: String
    let updateProgressAction: (Int) async -> Void
    let createCommentAction: () async -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PollenSpacing.medium) {
                if let readingProgress = summary.readingProgress {
                    ReadingProgressSummaryView(
                        progress: readingProgress,
                        pageCount: summary.activeBook?.pageCount,
                        updateAction: updateProgressAction
                    )

                    CommentComposerView(
                        bodyText: $newCommentBody,
                        pageText: $newCommentPageText,
                        currentPage: readingProgress.currentPage,
                        createAction: createCommentAction
                    )
                    .padding(PollenSpacing.medium)
                    .background(PollenColors.groupedBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
            .padding(PollenSpacing.large)
        }
        .background(PollenColors.background)
        .navigationTitle("Ações do clube")
        .navigationBarTitleDisplayMode(.inline)
    }
}
