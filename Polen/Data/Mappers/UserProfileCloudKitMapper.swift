import CloudKit
import Foundation

extension CKRecord {
    func update(with profile: UserProfile) throws {
        self[CloudKitField.Shared.id] = profile.id.uuidString
        self[CloudKitField.UserProfile.appleUserIdentifier] = profile.appleUserIdentifier
        self[CloudKitField.UserProfile.displayName] = profile.displayName
        self[CloudKitField.UserProfile.avatarAssetName] = profile.avatarAssetName
        self[CloudKitField.UserProfile.biography] = profile.biography
        self[CloudKitField.UserProfile.createdAt] = profile.createdAt

        if let avatarImageData = profile.avatarImageData {
            self[CloudKitField.UserProfile.avatarImage] = try CKAsset(avatarImageData: avatarImageData, profileID: profile.id)
        } else {
            self[CloudKitField.UserProfile.avatarImage] = nil
        }
    }
}

extension UserProfile {
    init(record: CKRecord) throws {
        let avatarAsset = record[CloudKitField.UserProfile.avatarImage] as? CKAsset
        let avatarImageData = avatarAsset?.fileURL.flatMap { try? Data(contentsOf: $0) }

        self.init(
            id: try record.uuid(for: CloudKitField.Shared.id),
            appleUserIdentifier: try record.string(for: CloudKitField.UserProfile.appleUserIdentifier),
            displayName: try record.string(for: CloudKitField.UserProfile.displayName),
            avatarAssetName: record.optionalString(for: CloudKitField.UserProfile.avatarAssetName),
            avatarImageData: avatarImageData,
            biography: record.optionalString(for: CloudKitField.UserProfile.biography),
            createdAt: try record.date(for: CloudKitField.UserProfile.createdAt)
        )
    }
}

private extension CKAsset {
    convenience init(avatarImageData: Data, profileID: UUID) throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appending(path: "polen-avatar-\(profileID.uuidString).jpg")
        try avatarImageData.write(to: fileURL, options: [.atomic])
        self.init(fileURL: fileURL)
    }
}

private extension CKRecord {
    func string(for field: String) throws -> String {
        guard let value = self[field] as? String else {
            throw CloudKitRecordMappingError.missingField(field)
        }

        return value
    }

    func optionalString(for field: String) -> String? {
        self[field] as? String
    }

    func uuid(for field: String) throws -> UUID {
        let value = try string(for: field)

        guard let uuid = UUID(uuidString: value) else {
            throw CloudKitRecordMappingError.invalidField(field)
        }

        return uuid
    }

    func date(for field: String) throws -> Date {
        guard let value = self[field] as? Date else {
            throw CloudKitRecordMappingError.missingField(field)
        }

        return value
    }
}
