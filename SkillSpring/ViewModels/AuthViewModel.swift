import Foundation
import FirebaseAuth
import Combine

// MARK: - AuthViewModel
// Drives OTPEntryView and LoginView.
// Wired to real Firebase Phone Authentication.

@MainActor
class AuthViewModel: ObservableObject {

    // MARK: - Published State
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

    // MARK: - Step 1: Send OTP

    func sendOTP() {
        guard !phoneNumber.isEmpty else {
            errorMessage = "Please enter your phone number."
            return
        }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let id = try await self.firebaseService.sendPhoneNumberOTP(phoneNumber: phoneNumber)
                self.verificationID = id
                self.navigateToOTP = true
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }

    // MARK: - Step 2: Verify OTP

    func verifyCode() {
        guard let verificationID, !verificationCode.isEmpty else {
            errorMessage = "Please enter the verification code."
            return
        }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let result = try await self.firebaseService.verifyOTP(
                    verificationID: verificationID,
                    verificationCode: verificationCode
                )
                let uid = result.uid
                let isNewUser = result.isNewUser

                if isNewUser {
                    // Create user profile in Firestore for the first time
                    await createUserProfile(uid: uid)
                    self.navigateToSkillSetup = true
                } else {
                    // Existing user — seed their data and go home
                    await DataSeeder.shared.seedAll()
                    UserDefaults.standard.set(true, forKey: "skillspryng.isLoggedIn")
                    self.navigateToSuccess = true
                }

                HapticManager.success()
            } catch {
                self.errorMessage = error.localizedDescription
                HapticManager.error()
            }
            self.isLoading = false
        }
    }

    // MARK: - Create User Profile (new users only)

    private func createUserProfile(uid: String) async {
        let newUser = User(
            id: uid,
            fullName: fullName.isEmpty ? "SkillSpryng User" : fullName,
            email: "",
            phoneNumber: phoneNumber,
            walletBalance: 500   // Welcome bonus
        )
        do {
            try await FirebaseManager.shared.saveUser(newUser)
            // Write welcome notification
            await FirebaseDataService.shared.createNotification(
                AppNotification(
                    type: .systemAlert,
                    title: "Welcome to SkillSpryng! 🎉",
                    body: "You have been given 500 SKP starter credits. Find a mentor and book your first session!",
                    referenceId: nil
                )
            )
            // Seed all collections for new user
            await DataSeeder.shared.seedAll()
            UserDefaults.standard.set(true, forKey: "skillspryng.isLoggedIn")
        } catch {
            print("[AuthViewModel] createUserProfile error: \(error.localizedDescription)")
        }
    }

    // MARK: - Biometric Auth (returning users)

    func authenticateWithBiometrics() {
        isLoading = true
        errorMessage = nil
        Task {
            let success = await BiometricAuthService.shared.authenticate()
            self.isLoading = false
            if success {
                HapticManager.success()
                UserDefaults.standard.set(true, forKey: "skillspryng.isLoggedIn")
            } else {
                HapticManager.error()
            }
        }
    }
}
