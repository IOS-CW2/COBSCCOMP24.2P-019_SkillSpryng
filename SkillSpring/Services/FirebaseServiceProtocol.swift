import Foundation
import FirebaseAuth

/// Wraps Firebase Authentication result data for easier handling.
/// Used to communicate authentication success and whether the user is new.
struct AuthResultProxy {
    /// The authenticated user's unique Firebase UID.
    let uid: String
    /// True if this is the user's first time signing up.
    let isNewUser: Bool
}

/// Protocol defining the interface for Firebase authentication and user data operations.
/// Allows for easy testing and mocking without creating Firebase dependencies.
protocol FirebaseService {
    /// Sends an OTP to the provided phone number.
    /// Returns a verification ID that must be used with verifyOTP.
    func sendPhoneNumberOTP(phoneNumber: String) async throws -> String
    
    /// Verifies the OTP code and completes authentication.
    /// Returns authentication result containing the user's UID and new user flag.
    func verifyOTP(verificationID: String, verificationCode: String) async throws -> AuthResultProxy
    
    /// Signs out the current user from Firebase.
    func signOut() throws
    
    /// Saves or updates user profile data to Firebase Firestore.
    func saveUser(_ user: User) async throws
    
    /// Fetches the current user's profile from Firebase Firestore.
    /// Returns nil if no user document exists.
    func fetchUser() async throws -> User?
    
    /// Fetches the locally cached user profile from Core Data.
    /// Used for offline access and quick app launches.
    func fetchLocalUser() -> LocalUser?
}
