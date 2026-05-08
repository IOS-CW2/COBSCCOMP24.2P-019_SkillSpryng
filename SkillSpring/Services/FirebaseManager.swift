import Foundation
@preconcurrency import FirebaseAuth
@preconcurrency import FirebaseFirestore
import UIKit
@preconcurrency import CoreData
import Combine

class PhoneAuthUIDelegate: NSObject, AuthUIDelegate {
    private func topViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return nil
        }
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        return topVC
    }
    
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            self.topViewController()?.present(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
    
    func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            self.topViewController()?.dismiss(animated: flag, completion: completion)
        }
    }
}

@MainActor
/// Handles Firebase authentication and Firestore user persistence.
///
/// Implements the shared FirebaseService protocol so the app can swap
/// between real Firebase and mock services during testing.
class FirebaseManager: FirebaseService {
    static let shared = FirebaseManager()
    
    lazy var auth: Auth = Auth.auth()
    lazy var firestore: Firestore = Firestore.firestore()
    private var _authUIDelegate: PhoneAuthUIDelegate?
    private var authUIDelegate: PhoneAuthUIDelegate {
        if _authUIDelegate == nil {
            _authUIDelegate = PhoneAuthUIDelegate()
        }
        return _authUIDelegate!
    }
    
    private static let simulatorUserDefaultsKey = "skillspryng.simulatorUserID"
    private var simulatorUserID: String?

    static var currentUID: String? {
        return Auth.auth().currentUser?.uid ?? shared.simulatorUserID
    }

    func setSimulatorUserID(_ id: String?) {
        simulatorUserID = id
        if let id {
            UserDefaults.standard.set(id, forKey: Self.simulatorUserDefaultsKey)
        } else {
            UserDefaults.standard.removeObject(forKey: Self.simulatorUserDefaultsKey)
        }
    }

    private init() {
        #if targetEnvironment(simulator)
        simulatorUserID = UserDefaults.standard.string(forKey: Self.simulatorUserDefaultsKey)
        #endif
        #if targetEnvironment(simulator)
        // Disable app verification for simulator testing so Phone Auth does not require reCAPTCHA.
        auth.settings?.isAppVerificationDisabledForTesting = true
        #endif
    }
    
    // MARK: - Phone Authentication
    
    private static let phoneAuthTestNumber = "+94727965292"
    private static let phoneAuthTestCode = "123456"
    private static let phoneAuthTestVerificationID = "skillspryng-test-verification-id"
    
    func sendPhoneNumberOTP(phoneNumber: String) async throws -> String {
        if phoneNumber == Self.phoneAuthTestNumber {
            return Self.phoneAuthTestVerificationID
        }

        let verificationID = try await PhoneAuthProvider.provider().verifyPhoneNumber(
            phoneNumber,
            uiDelegate: authUIDelegate
        )
        return verificationID
    }
    
    func verifyOTP(verificationID: String, verificationCode: String) async throws -> AuthResultProxy {
        if verificationID == Self.phoneAuthTestVerificationID && verificationCode == Self.phoneAuthTestCode {
            // For simulator testing: bypass real phone verification entirely.
            // Try anonymous auth first, otherwise fall back to a persistent simulator UID.
            if let currentUser = auth.currentUser {
                setSimulatorUserID(currentUser.uid)
                return AuthResultProxy(uid: currentUser.uid, isNewUser: false)
            }
            if let storedUID = simulatorUserID {
                return AuthResultProxy(uid: storedUID, isNewUser: false)
            }
            do {
                let result = try await auth.signInAnonymously()
                setSimulatorUserID(result.user.uid)
                return AuthResultProxy(uid: result.user.uid, isNewUser: result.additionalUserInfo?.isNewUser ?? true)
            } catch {
                let generatedUID = "sim-" + UUID().uuidString
                setSimulatorUserID(generatedUID)
                return AuthResultProxy(uid: generatedUID, isNewUser: true)
            }
        }

        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )
        let result = try await auth.signIn(with: credential)
        return AuthResultProxy(uid: result.user.uid, isNewUser: result.additionalUserInfo?.isNewUser ?? false)
    }
    
    func signOut() throws {
        if auth.currentUser != nil {
            try auth.signOut()
        }
        // Keep simulatorUserID stored so the same simulated account can be reused
        // on next sign-in with the test phone number.
    }
    
    // MARK: - Firestore Operations
    
    func saveUser(_ user: User) async throws {
        guard let uid = Self.currentUID else {
            throw NSError(domain: "FirebaseManager", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }
        var u = user
        u.id = uid
        try firestore.collection("users").document(uid).setData(from: u)
    }
    
    func fetchUser() async throws -> User? {
        guard let uid = Self.currentUID else {
            throw NSError(domain: "FirebaseManager", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }
        let snapshot = try await firestore.collection("users").document(uid).getDocument()
        guard snapshot.exists else { return nil }
        var user = try snapshot.data(as: User.self)
        user.id = snapshot.documentID
        
        // Cache to Core Data
        saveUserLocally(user)
        
        return user
    }
    
    // MARK: - Core Data Persistence
    
    /// Caches the authenticated user locally in Core Data.
    /// This is used to support offline access and faster app startup.
    private func saveUserLocally(_ user: User) {
        let context = PersistenceController.shared.container.viewContext
        
        // Check if user already exists
        let fetchRequest: NSFetchRequest<LocalUser> = NSFetchRequest<LocalUser>(entityName: "LocalUser")
        fetchRequest.predicate = NSPredicate(format: "id == %@", user.id ?? "")
        
        context.perform {
            do {
                let results = try context.fetch(fetchRequest)
                let localUser = results.first ?? LocalUser(context: context)
                
                localUser.id = user.id
                localUser.fullName = user.fullName
                localUser.phoneNumber = user.phoneNumber
                localUser.experienceLevel = user.experienceLevel
                localUser.location = user.location
                localUser.bio = user.bio
                let incomingProfileImageURL = user.profileImageURL.trimmingCharacters(in: .whitespacesAndNewlines)
                if !incomingProfileImageURL.isEmpty {
                    localUser.profileImageURL = user.profileImageURL
                } else if localUser.profileImageURL == nil || localUser.profileImageURL?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
                    localUser.profileImageURL = user.profileImageURL
                }

                try context.save()
            } catch {
                print("Failed to save user to Core Data: \(error)")
            }
        }
    }
    
    /// Returns the locally cached user profile from Core Data, if available.
    func fetchLocalUser() -> LocalUser? {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<LocalUser> = NSFetchRequest<LocalUser>(entityName: "LocalUser")
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Failed to fetch local user: \(error)")
            return nil
        }
    }
    
    // MARK: - StoreKit / Monetisation Sync
    
    /// Called after a successful Pro subscription purchase to mark the user as premium in Firestore.
    func updateUserPro(isPremium: Bool, expiryDate: Date?) async {
        guard let uid = auth.currentUser?.uid else {
            print("[Firebase] updateUserPro: No authenticated user — skipping Firestore write.")
            return
        }
        var data: [String: Any] = ["isPremium": isPremium]
        if let expiry = expiryDate {
            data["proExpiryDate"] = expiry
        }
        do {
            try await firestore.collection("users").document(uid).updateData(data)
            print("[Firebase] ✅ User pro status updated: isPremium=\(isPremium)")
        } catch {
            print("[Firebase] ❌ Failed to update pro status: \(error)")
        }
    }
    
    /// Called after a successful credits purchase to add the purchased amount to the user's wallet in Firestore.
    /// NOTE: writes to the "walletBalance" field — same field used by FirebaseDataService.updateWalletBalance()
    ///       and fetchCurrentUser(). Previously this wrote to a separate "credits" field which caused the
    ///       wallet UI to show the wrong balance after a StoreKit purchase.
    func addCredits(amount: Int) async {
        guard let uid = auth.currentUser?.uid else {
            print("[Firebase] addCredits: No authenticated user — skipping Firestore write.")
            return
        }
        do {
            try await firestore.collection("users").document(uid).updateData([
                "walletBalance": FieldValue.increment(Int64(amount))
            ])
            print("[Firebase] ✅ walletBalance incremented by \(amount)")
        } catch {
            print("[Firebase] ❌ Failed to add credits: \(error)")
        }
    }
}
