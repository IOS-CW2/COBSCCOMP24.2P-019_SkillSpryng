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
    
    func sendOTP() {
        guard !fullName.isEmpty, !phoneNumber.isEmpty else {
            errorMessage = "Please enter your full name and phone number."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let formattedNumber = phoneNumber.starts(with: "+") ? phoneNumber : "+\(phoneNumber)"
        
        Task {
            do {
                let id = try await FirebaseManager.shared.sendPhoneNumberOTP(phoneNumber: formattedNumber)
                self.isLoading = false
                self.verificationID = id
                self.navigateToOTP = true
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
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
            do {
                let _ = try await FirebaseManager.shared.verifyOTP(verificationID: verificationID, verificationCode: verificationCode)
                // Check if user exists in Firestore
                let _ = try? await FirebaseManager.shared.fetchUser()
                self.navigateToSuccess = true
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
}
