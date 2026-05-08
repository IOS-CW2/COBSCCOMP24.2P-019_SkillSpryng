import Foundation
import Combine
import UIKit
import CoreLocation

// MARK: - SkillSetupViewModel
// Drives the new-user Skill Setup flow (SkillSetupView).
// Collects the user's teach/learn skills, experience level, location, bio,
// and optional profile photo, then writes the completed User document to
// Firestore via FirebaseDataService and seeds initial data via DataSeeder.
// Architecture: SkillSetupView → SkillSetupViewModel → FirebaseDataService → Firestore

@MainActor
class SkillSetupViewModel: ObservableObject {
    @Published var selectedTeachSkills: Set<String> = []
    @Published var selectedLearnSkills: Set<String> = []
    @Published var experienceLevel: ExperienceLevel = .beginner
    @Published var location: String = ""
    @Published var selectedLocation: CLLocationCoordinate2D? = nil
    @Published var bio: String = ""
    @Published var isLocationEnabled: Bool = true
    @Published var selectedImage: UIImage? = nil
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isSetupComplete: Bool = false
    
    private let firebaseService: FirebaseService
    
    init(firebaseService: FirebaseService? = nil) {
        self.firebaseService = firebaseService ?? FirebaseManager.shared
    }
    
    let availableTeachSkills = ["UI Design", "Photography", "React", "Swift", "Marketing"]
    let availableLearnSkills = ["Piano", "Spanish", "Surfing", "Python", "Data Science"]
    
    enum ExperienceLevel: String, CaseIterable, Identifiable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case expert = "Expert"
        var id: String { self.rawValue }
    }
    
    /// Adds or removes a teaching skill selection.
    /// Uses `Set` semantics to avoid duplicate skill entries.
    func toggleTeachSkill(_ skill: String) {
        var copy = selectedTeachSkills
        if copy.contains(skill) {
            copy.remove(skill)
        } else {
            copy.insert(skill)
        }
        selectedTeachSkills = copy
    }
    
    /// Adds or removes a learning skill selection.
    /// The selected skill list is stored as a Set for uniqueness.
    func toggleLearnSkill(_ skill: String) {
        var copy = selectedLearnSkills
        if copy.contains(skill) {
            copy.remove(skill)
        } else {
            copy.insert(skill)
        }
        selectedLearnSkills = copy
    }
    
    /// Finalizes the user's skill setup profile and saves it to Firestore.
    /// Also caches the profile locally and seeds starter app data.
    func saveProfile(fullName: String, phoneNumber: String, markLoggedIn: Bool = false, isChildMode: Bool = false) async {
        isLoading = true
        defer { isLoading = false }

        var user = User(
            fullName: fullName,
            phoneNumber: phoneNumber,
            skillsToTeach: Array(selectedTeachSkills),
            skillsToLearn: Array(selectedLearnSkills),
            experienceLevel: experienceLevel.rawValue,
            location: isLocationEnabled ? location : "",
            bio: bio,
            profileImageURL: ""
        )
        user.isChildMode = isChildMode

        if isLocationEnabled, let selectedLocation {
            user.latitude = selectedLocation.latitude
            user.longitude = selectedLocation.longitude
        }

        PersistenceService.shared.saveUser(user)

        do {
            try await FirebaseDataService.shared.saveUser(user)

            if let image = selectedImage {
                do {
                    let url = try await FirebaseStorageService.shared.uploadProfileImage(image)
                    user.profileImageURL = url
                    PersistenceService.shared.saveUser(user)
                    try await FirebaseDataService.shared.saveUser(user)
                } catch {
                    print("[SkillSetup] profile image upload failed: \(error.localizedDescription)")
                }
            }

            await DataSeeder.shared.seedAll()
            if markLoggedIn {
                UserDefaults.standard.set(true, forKey: "skillspryng.isLoggedIn")
                isSetupComplete = true
            }
        } catch {
            errorMessage = error.localizedDescription
            print("[SkillSetup] Firestore save failed: \(error.localizedDescription)")
        }
    }
}
