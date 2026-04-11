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
    
    init(firebaseService: FirebaseService? = nil) {
        self.firebaseService = firebaseService ?? FirebaseManager.shared
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
            HapticManager.success()
            self.navigateToSuccess = true
            self.isLoading = false
        }
    }
    
    func authenticateWithBiometrics() {
        isLoading = true
        errorMessage = nil
        Task {
            let success = await BiometricAuthService.shared.authenticate()
            self.isLoading = false
            if success {
                HapticManager.success()
                // Set login flag — RootCoordinatorView switches to MainTabView automatically
                UserDefaults.standard.set(true, forKey: "skillspryng.isLoggedIn")
            } else {
                HapticManager.error()
            }
            // Errors shown via BiometricAuthService.shared.errorMessage in the view
        }
    }
}
