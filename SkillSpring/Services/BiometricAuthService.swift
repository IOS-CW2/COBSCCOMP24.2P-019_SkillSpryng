import Foundation
import LocalAuthentication
import Combine

class BiometricAuthService: ObservableObject {
    static let shared = BiometricAuthService()
    
    @Published var isSupported: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String? = nil
    
    private init() {
        checkBiometricSupport()
    }
    
    func checkBiometricSupport() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            isSupported = true
        } else {
            isSupported = false
        }
    }
    
    func authenticate() async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            DispatchQueue.main.async {
                self.errorMessage = "Biometrics not enrolled or supported."
            }
            return false
        }
        
        let reason = "Unlock SkillSpring with Face ID."
        
        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            DispatchQueue.main.async {
                self.isAuthenticated = success
                self.errorMessage = success ? nil : "Authentication failed."
            }
            return success
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isAuthenticated = false
            }
            return false
        }
    }
}
