import Foundation

struct SaveUserProfileUseCase: Sendable {
    private let userProfileRepository: UserProfileRepository

    init(userProfileRepository: UserProfileRepository) {
        self.userProfileRepository = userProfileRepository
    }

    func execute(profile: UserProfile) async throws {
        try await userProfileRepository.save(profile)
    }
}
