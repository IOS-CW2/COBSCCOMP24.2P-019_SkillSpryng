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
        guard !fullName.isEmpty, !phoneNumber.isEmpty else {
            errorMessage = "Please enter your full name and phone number."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let formattedNumber = phoneNumber.starts(with: "+") ? phoneNumber : "+\(phoneNumber)"
        
        Task {
            // Temporarily mocked to bypass for UI testing
            self.isLoading = false
            self.verificationID = "MOCK_ID"
            self.navigateToOTP = true
        }
    }
    
    func verifyCode() {
        guard let verificationID = verificationID, !verificationCode.isEmpty else {
            errorMessage = "Missing verification ID or code."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            // Temporarily mocked to bypass for UI testing
            self.navigateToSuccess = true
            self.isLoading = false
        }
    }
    
    func authenticateWithBiometrics() {
        // Temporarily mocked to bypass for UI testing
        self.navigateToSuccess = true
    }
}
