import SwiftData

struct SwiftDataContainer {
    let modelContainer: ModelContainer

    static func makeLive() -> SwiftDataContainer {
        let schema = Schema([
            StoredUserProfile.self,
            StoredReadingProgress.self,
            StoredUserSettings.self,
            StoredBook.self,
            StoredBookClub.self,
            StoredMembership.self,
            StoredComment.self,
            StoredReply.self,
            StoredPollenNotification.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )

        do {
            return SwiftDataContainer(
                modelContainer: try ModelContainer(for: schema, configurations: [configuration])
            )
        } catch {
            fatalError("Could not create SwiftData ModelContainer: \(error)")
        }
    }
}
