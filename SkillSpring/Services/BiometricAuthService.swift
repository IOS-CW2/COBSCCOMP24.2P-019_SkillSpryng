import Foundation
import LocalAuthentication
import Combine

/// Manages biometric authentication for SkillSpryng.
///
/// Handles Face ID / Touch ID support checks, biometric login persistence,
/// and user-friendly error messages for common biometric failures.
@MainActor
class BiometricAuthService: ObservableObject {
    static let shared = BiometricAuthService()
    
    @Published var isSupported: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String? = nil
    
    /// Whether the user has opted in to biometric login (persisted across launches)
    @Published var isBiometricLoginEnabled: Bool = UserDefaults.standard.bool(forKey: "skillspryng.biometricLoginEnabled") {
        didSet {
            UserDefaults.standard.set(isBiometricLoginEnabled, forKey: "skillspryng.biometricLoginEnabled")
        }
    }
    
    /// Returns "Face ID", "Touch ID", or "Biometrics" depending on the device
    var biometricType: String {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return "Biometrics"
        }
        switch context.biometryType {
        case .faceID:  return "Face ID"
        case .touchID: return "Touch ID"
        default:       return "Biometrics"
        }
    }
    
    /// SF Symbol name matching the biometric type
    var biometricIcon: String {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return "faceid"
        }
        return context.biometryType == .touchID ? "touchid" : "faceid"
    }
    
    /// Returns true if the device has biometric HARDWARE (even if not enrolled yet).
    /// Use this to decide whether to SHOW the toggle in Settings.
    var hasBiometricHardware: Bool {
        let context = LAContext()
        var error: NSError?
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if let laError = error as? LAError {
            // biometryNotEnrolled = hardware exists but user hasn't set it up yet
            return laError.code == .biometryNotEnrolled
        }
        return true // no error = fully supported and enrolled
    }
    
    private init() {
        checkBiometricSupport()
    }
    
    /// Checks whether this device can evaluate biometric authentication.
    /// Updates `isSupported` so the UI can show or hide biometric login options.
    func checkBiometricSupport() {
        let context = LAContext()
        var error: NSError?
        isSupported = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    /// Prompts the user to authenticate with Face ID / Touch ID.
    /// Returns true on success and updates internal state and error messages.
    func authenticate() async -> Bool {
        // Always create a fresh LAContext — reusing one after failure causes silent no-ops
        let context = LAContext()
        var canEvalError: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &canEvalError) else {
            errorMessage = canEvalError?.localizedDescription ?? "Biometrics not enrolled or supported."
            isAuthenticated = false
            return false
        }
        
        let reason = "Sign in to SkillSpryng with \(biometricType)."
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            isAuthenticated = success
            errorMessage = nil
            return success
            
        } catch let laError as LAError {
            isAuthenticated = false
            switch laError.code {
            case .userCancel, .systemCancel, .appCancel:
                // User deliberately dismissed — don't show an error
                errorMessage = nil
                
            case .biometryLockout:
                errorMessage = "\(biometricType) is locked after too many failed attempts. Please unlock your device with your passcode first."
                
            case .authenticationFailed:
                errorMessage = "\(biometricType) did not recognise you. Tap the button to try again."
                
            case .biometryNotEnrolled:
                errorMessage = "No \(biometricType) is set up. Go to Settings → \(biometricType) & Passcode to enrol."
                
            case .biometryNotAvailable:
                isSupported = false
                errorMessage = "\(biometricType) is not available on this device."
                
            default:
                errorMessage = laError.localizedDescription
            }
            return false
            
        } catch {
            isAuthenticated = false
            errorMessage = error.localizedDescription
            return false
        }
    }
}
