import UIKit
import Foundation
import Combine
import FirebaseAuth

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

    func deductBalance(amount: Int) async {
        user.walletBalance -= amount
        await FirebaseDataService.shared.updateWalletBalance(user.walletBalance)
    }

    func addBalance(amount: Int) async {
        user.walletBalance += amount
        await FirebaseDataService.shared.updateWalletBalance(user.walletBalance)
    }

    // MARK: - Profile Image Upload

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

    func addTeachingSkill(_ skill: String) async {
        guard !skill.isEmpty, !user.skillsToTeach.contains(skill) else { return }
        user.skillsToTeach.append(skill)
        await saveProfile()
    }

    func removeTeachingSkill(_ skill: String) async {
        user.skillsToTeach.removeAll { $0 == skill }
        await saveProfile()
    }

    func addLearningSkill(_ skill: String) async {
        guard !skill.isEmpty, !user.skillsToLearn.contains(skill) else { return }
        user.skillsToLearn.append(skill)
        await saveProfile()
    }

    // MARK: - Update Availability

    func toggleAvailability(day: String) async {
        if user.availabilityDays.contains(day) {
            user.availabilityDays.removeAll { $0 == day }
        } else {
            user.availabilityDays.append(day)
        }
        await saveProfile()
    }

    // MARK: - Sign Out

    func signOut() {
        try? FirebaseManager.shared.signOut()
        UserDefaults.standard.set(false, forKey: "skillspryng.isLoggedIn")
    }
}
