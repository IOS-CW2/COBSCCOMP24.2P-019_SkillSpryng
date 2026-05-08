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
    
    var verifyOTPResult: Result<AuthResultProxy, Error> = .success(AuthResultProxy(uid: "USER_ID_123", isNewUser: false))
    
    func verifyOTP(verificationID: String, verificationCode: String) async throws -> AuthResultProxy {
        if !shouldSucceed {
            throw NSError(domain: "MockError", code: -1, userInfo: nil)
        }
        
        switch verifyOTPResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
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
