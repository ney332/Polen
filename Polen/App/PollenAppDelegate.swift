import CloudKit
import UIKit

@MainActor
final class PollenAppDelegate: NSObject, UIApplicationDelegate {
    var shareAcceptanceHandler: ((CKShare.Metadata) -> Void)?

    func application(
        _ application: UIApplication,
        userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata
    ) {
        shareAcceptanceHandler?(cloudKitShareMetadata)
    }
}
