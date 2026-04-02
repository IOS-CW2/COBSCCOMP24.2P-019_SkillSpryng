import Foundation
import FirebaseAuth
import FirebaseFirestore
import UIKit

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

class FirebaseManager {
    static let shared = FirebaseManager()
    
    let auth: Auth
    let firestore: Firestore
    private let authUIDelegate = PhoneAuthUIDelegate()
    
    private init() {
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
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
        return user
    }
}
