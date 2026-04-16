import Foundation
import FirebaseAuth

struct AuthResultProxy {
    let uid: String
    let isNewUser: Bool
}

protocol FirebaseService {
    func sendPhoneNumberOTP(phoneNumber: String) async throws -> String
    func verifyOTP(verificationID: String, verificationCode: String) async throws -> AuthResultProxy
    func signOut() throws
    func saveUser(_ user: User) async throws
    func fetchUser() async throws -> User?
    func fetchLocalUser() -> LocalUser?
}
