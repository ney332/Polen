import CloudKit
import SwiftUI
import UIKit

struct CloudClubSharingView: UIViewControllerRepresentable {
    let summary: HomeClubSummary
    let shareStore: CloudKitClubInviteShareStore

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UICloudSharingController {
        let controller = UICloudSharingController { _, completion in
            Task {
                do {
                    let preparedShare = try await shareStore.prepareShare(for: summary)
                    completion(preparedShare.share, preparedShare.container, nil)
                } catch {
                    completion(nil, nil, error)
                }
            }
        }

        controller.delegate = context.coordinator
        controller.availablePermissions = [.allowPrivate, .allowReadWrite]
        return controller
    }

    func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss, clubName: summary.clubName)
    }

    final class Coordinator: NSObject, UICloudSharingControllerDelegate {
        private let dismiss: DismissAction
        private let clubName: String

        init(dismiss: DismissAction, clubName: String) {
            self.dismiss = dismiss
            self.clubName = clubName
        }

        func itemTitle(for csc: UICloudSharingController) -> String? {
            "Convite para \(clubName)"
        }

        func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
            dismiss()
        }

        func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
            dismiss()
        }

        func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
            dismiss()
        }
    }
}
