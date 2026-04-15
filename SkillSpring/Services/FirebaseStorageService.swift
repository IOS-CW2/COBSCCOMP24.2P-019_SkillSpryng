import Foundation
import UIKit

// MARK: - FirebaseStorageService (MOCK)
// FirebaseStorage was not linked in the project so this is a functional stub.
@MainActor
final class FirebaseStorageService {
    static let shared = FirebaseStorageService()
    private init() {}

    func uploadProfileImage(_ image: UIImage) async throws -> String {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let simulatedURL = "instructor1" 
        if var user = await FirebaseDataService.shared.fetchCurrentUser() {
            user.profileImageURL = simulatedURL
            try? await FirebaseDataService.shared.saveUser(user)
        }
        return simulatedURL
    }

    func fetchProfileImageURL() async -> String? {
        return nil
    }

    func deleteProfileImage() async throws {}

    func uploadSessionRecording(sessionId: String, data: Data) async throws -> String {
        return "mock_video_url"
    }

    enum StorageError: LocalizedError {
        case notAuthenticated
        case invalidImageData
        var errorDescription: String? {
            switch self {
            case .notAuthenticated: return "You must be signed in to upload files."
            case .invalidImageData: return "Could not convert image to upload format."
            }
        }
    }
}
