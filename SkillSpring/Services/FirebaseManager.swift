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
    
    private init() {
        // Initializer is now empty as properties are lazy
    }
    
    // MARK: - Phone Authentication
    
    func sendPhoneNumberOTP(phoneNumber: String) async throws -> String {
        let verificationID = try await PhoneAuthProvider.provider().verifyPhoneNumber(
            phoneNumber,
            uiDelegate: authUIDelegate
        )
        return verificationID
    }
    
    func verifyOTP(verificationID: String, verificationCode: String) async throws -> AuthDataResult {
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )
        let result = try await auth.signIn(with: credential)
        return result
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    // MARK: - Firestore Operations
    
    func saveUser(_ user: User) async throws {
        guard let uid = auth.currentUser?.uid else {
            throw NSError(domain: "FirebaseManager", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }
        try firestore.collection("users").document(uid).setData(from: user)
    }
    
    func fetchUser() async throws -> User? {
        guard let uid = auth.currentUser?.uid else {
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
                localUser.profileImageURL = user.profileImageURL
                
                try context.save()
            } catch {
                print("Failed to save user to Core Data: \(error)")
            }
        }
    }
    
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
    
    /// Called after a successful credits purchase to add the purchased amount to the user's balance in Firestore.
    func addCredits(amount: Int) async {
        guard let uid = auth.currentUser?.uid else {
            print("[Firebase] addCredits: No authenticated user — skipping Firestore write.")
            return
        }
        do {
            try await firestore.collection("users").document(uid).updateData([
                "credits": FieldValue.increment(Int64(amount))
            ])
            print("[Firebase] ✅ Credits incremented by \(amount)")
        } catch {
            print("[Firebase] ❌ Failed to add credits: \(error)")
        }
    }
}
