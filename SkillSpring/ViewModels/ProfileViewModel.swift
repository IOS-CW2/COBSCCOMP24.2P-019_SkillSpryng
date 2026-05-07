import UIKit
import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

// MARK: - ProfileViewModel
// Drives ProfileView, EditProfileView, MySkillsView, SettingsView, WalletView.
// User profile loaded from Firestore. Profile image uploaded via FirebaseStorageService.

@MainActor
final class ProfileViewModel: ObservableObject {

    // MARK: - Published State
    @Published var user: User = User(id: nil, fullName: "", email: "", phoneNumber: "")
    @Published var isLoading: Bool = false
    @Published var isSaving: Bool = false
    @Published var profileImageUploadProgress: Double = 0
    @Published var errorMessage: String?

    // MARK: - Init
    init() {
        Task { await loadProfile() }
    }

    // MARK: - Load Profile from Firestore

    /// Loads the current user's profile from Firestore.
    /// If Firestore is unavailable, falls back to locally cached Core Data data.
    func loadProfile() async {
        isLoading = true
        if let fetched = await FirebaseDataService.shared.fetchCurrentUser() {
            user = fetched
            // Write-through: keep the local Core Data cache fresh so the
            // offline path always has the most recent profile available.
            PersistenceService.shared.saveUser(fetched)
        } else if let cached = PersistenceService.shared.fetchUser() {
            // Offline fallback: Firestore unreachable — serve cached profile
            // rather than showing a blank screen (Core Data requirement §2.1.8).
            user = cached
        }
        isLoading = false
    }

    // MARK: - Save Profile to Firestore

    /// Persists the current profile object to Firestore.
    /// Updates UI state and captures any save error messages.
    func saveProfile() async {
        isSaving = true
        do {
            try await FirebaseDataService.shared.saveUser(user)
            print("[ProfileViewModel] ✅ Profile saved.")
        } catch {
            errorMessage = error.localizedDescription
            print("[ProfileViewModel] ❌ saveProfile error: \(error)")
        }
        isSaving = false
    }

    // MARK: - Wallet Operations

    /// Decreases the user's wallet balance and syncs the change to Firestore.
    func deductBalance(amount: Int) async {
        user.walletBalance -= amount
        await FirebaseDataService.shared.updateWalletBalance(user.walletBalance)
    }

    /// Increases the user's wallet balance and syncs it to Firestore.
    func addBalance(amount: Int) async {
        user.walletBalance += amount
        await FirebaseDataService.shared.updateWalletBalance(user.walletBalance)
    }

    // MARK: - Profile Image Upload

    /// Uploads a profile picture to Firebase Storage and updates the user's profile URL.
    func uploadProfileImage(_ imageData: Data) async {
        guard let image = UIImage(data: imageData) else { return }
        isSaving = true
        do {
            let url = try await FirebaseStorageService.shared.uploadProfileImage(image)
            user.profileImageURL = url
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }

    // MARK: - Update Skills

    /// Adds a new teaching skill and saves the updated profile.
    func addTeachingSkill(_ skill: String) async {
        guard !skill.isEmpty, !user.skillsToTeach.contains(skill) else { return }
        user.skillsToTeach.append(skill)
        await saveProfile()
    }

    /// Removes a teaching skill from the profile and saves the update.
    func removeTeachingSkill(_ skill: String) async {
        user.skillsToTeach.removeAll { $0 == skill }
        await saveProfile()
    }

    /// Adds a new learning skill and persists the change.
    func addLearningSkill(_ skill: String) async {
        guard !skill.isEmpty, !user.skillsToLearn.contains(skill) else { return }
        user.skillsToLearn.append(skill)
        await saveProfile()
    }

    // MARK: - Update Availability

    /// Toggles a day in the user's availability list and saves the profile.
    func toggleAvailability(day: String) async {
        if user.availabilityDays.contains(day) {
            user.availabilityDays.removeAll { $0 == day }
        } else {
            user.availabilityDays.append(day)
        }
        await saveProfile()
    }

    // MARK: - Profile Visibility

    /// Updates the user's profile visibility in Firestore.
    /// Called from SettingsView so the View doesn’t write directly to Firestore.
    func updateProfileVisibility(_ visibility: String) async {
        guard let uid = user.id else { return }
        do {
            try await FirebaseDataService.shared.db
                .collection("users").document(uid)
                .updateData(["visibility": visibility.lowercased()])
            user.role = user.role   // trigger objectWillChange so UI refreshes
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Child Safety Mode

    /// Writes `isChildMode` to Firestore and updates the local Core Data cache.
    /// `enabled = true`  → child-facing UI is active.
    /// `enabled = false` → parent/adult control panel is active.
    func updateChildMode(enabled: Bool) async {
        guard let uid = user.id else { return }
        do {
            try await FirebaseDataService.shared.db
                .collection("users").document(uid)
                .updateData(["isChildMode": enabled])
            user.isChildMode = enabled
            PersistenceService.shared.saveUser(user)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Account Deletion

    /// Permanently deletes the user's Firestore document and Firebase Auth account.
    /// Also clears local cache and cancels pending notifications.
    func deleteAccount() async {
        guard let uid = user.id else { return }
        isLoading = true
        do {
            try await FirebaseDataService.shared.db
                .collection("users").document(uid).delete()
            if let currentUser = Auth.auth().currentUser {
                try await currentUser.delete()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        PersistenceService.shared.clearCache()
        NotificationManager.shared.cancelAllPendingNotifications()
        UserDefaults.standard.set(false, forKey: "skillspryng.isLoggedIn")
        isLoading = false
    }

    // MARK: - Sign Out

    /// Signs the user out locally and clears the login flag.
    func signOut() {
        try? FirebaseManager.shared.signOut()
        UserDefaults.standard.set(false, forKey: "skillspryng.isLoggedIn")
    }
}
