import Foundation
import FirebaseAuth
@testable import SkillSpring

class MockFirebaseManager: FirebaseService {
    var shouldSucceed: Bool = true
    var mockUser: SkillSpring.User?
    
    // Result for specific error mocking in sendOTP
    var sendOTPResult: Result<String, Error> = .success("MOCK_VERIFICATION_ID")
    
    func sendPhoneNumberOTP(phoneNumber: String) async throws -> String {
        switch sendOTPResult {
        case .success(let id):
            // Fallback for older tests using shouldSucceed
            if !shouldSucceed { throw NSError(domain: "MockError", code: -1, userInfo: nil) }
            return id
        case .failure(let error):
            throw error
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
    
    func saveUser(_ user: SkillSpring.User) async throws {
        if !shouldSucceed {
            throw NSError(domain: "MockError", code: -1, userInfo: nil)
        }
        self.mockUser = user
    }
    
    func fetchUser() async throws -> SkillSpring.User? {
        if !shouldSucceed {
            throw NSError(domain: "MockError", code: -1, userInfo: nil)
        }
        return mockUser
    }
    
    func fetchLocalUser() -> LocalUser? {
        return nil
    }
}
