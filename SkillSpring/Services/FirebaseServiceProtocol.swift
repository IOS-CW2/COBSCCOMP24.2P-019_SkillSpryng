import Foundation
import FirebaseAuth

protocol FirebaseService {
    func sendPhoneNumberOTP(phoneNumber: String) async throws -> String
    func verifyOTP(verificationID: String, verificationCode: String) async throws -> AuthDataResult
    func signOut() throws
    func saveUser(_ user: User) async throws
    func fetchUser() async throws -> User?
    func fetchLocalUser() -> LocalUser?
}
