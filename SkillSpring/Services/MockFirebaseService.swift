import Foundation
import CoreData

/// Mock implementation of FirebaseService used for local testing and previews.
/// Provides deterministic behavior without hitting actual Firebase services.
final class MockFirebaseService: FirebaseService {
    func sendPhoneNumberOTP(phoneNumber: String) async throws -> String {
        // Return a deterministic verification ID for UI testing.
        return "mock-verification-id"
    }

    func verifyOTP(verificationID: String, verificationCode: String) async throws -> AuthResultProxy {
        return AuthResultProxy(uid: "mock-user-id", isNewUser: false)
    }

    func signOut() throws {
        // No-op for mock auth.
    }

    func saveUser(_ user: User) async throws {
        // No-op for mock auth.
    }

    func fetchUser() async throws -> User? {
        return nil
    }

    func fetchLocalUser() -> LocalUser? {
        return nil
    }
}
