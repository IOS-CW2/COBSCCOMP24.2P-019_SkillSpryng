import Foundation
import FirebaseAuth
@testable import SkillSpring

class MockFirebaseManager: FirebaseService {
    var shouldSucceed: Bool = true
    var mockUser: User?
    
    func sendPhoneNumberOTP(phoneNumber: String) async throws -> String {
        if shouldSucceed {
            return "MOCK_VERIFICATION_ID"
        } else {
            throw NSError(domain: "MockError", code: -1, userInfo: nil)
        }
    }
    
    func verifyOTP(verificationID: String, verificationCode: String) async throws -> AuthDataResult {
        if shouldSucceed {
            // This is complex to mock due to private initializers in Firebase,
            // but for simple ViewModel tests, we just care if it throws or not.
            fatalError("AuthDataResult mocking is complex; use protocol methods instead if results are needed.")
        } else {
            throw NSError(domain: "MockError", code: -1, userInfo: nil)
        }
    }
    
    func signOut() throws {
        // No-op
    }
    
    func saveUser(_ user: User) async throws {
        if !shouldSucceed {
            throw NSError(domain: "MockError", code: -1, userInfo: nil)
        }
        self.mockUser = user
    }
    
    func fetchUser() async throws -> User? {
        if !shouldSucceed {
            throw NSError(domain: "MockError", code: -1, userInfo: nil)
        }
        return mockUser
    }
    
    func fetchLocalUser() -> LocalUser? {
        return nil
    }
}
