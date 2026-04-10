import Foundation
import FirebaseAuth
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var fullName: String = ""
    @Published var phoneNumber: String = ""
    @Published var verificationCode: String = ""
    
    @Published var verificationID: String?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    @Published var navigateToOTP: Bool = false
    @Published var navigateToSuccess: Bool = false
    @Published var navigateToSkillSetup: Bool = false
    
    private let firebaseService: FirebaseService
    
    init(firebaseService: FirebaseService = FirebaseManager.shared) {
        self.firebaseService = firebaseService
    }
    
    func sendOTP() {
        isLoading = true
        errorMessage = nil
        Task {
            // BYPASSED for UI navigation testing
            self.isLoading = false
            self.verificationID = "MOCK_ID"
            self.navigateToOTP = true
        }
    }
    
    func verifyCode() {
        isLoading = true
        errorMessage = nil
        Task {
            // BYPASSED for UI navigation testing
            self.navigateToSuccess = true
            self.isLoading = false
        }
    }
    
    func authenticateWithBiometrics() {
        // Temporarily mocked to bypass for UI testing
        self.navigateToSuccess = true
    }
}
