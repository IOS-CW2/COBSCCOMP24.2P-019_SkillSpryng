import Foundation
import Combine
import UIKit

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
    
    func toggleTeachSkill(_ skill: String) {
        var copy = selectedTeachSkills
        if copy.contains(skill) {
            copy.remove(skill)
        } else {
            copy.insert(skill)
        }
        selectedTeachSkills = copy
    }
    
    func toggleLearnSkill(_ skill: String) {
        var copy = selectedLearnSkills
        if copy.contains(skill) {
            copy.remove(skill)
        } else {
            copy.insert(skill)
        }
        selectedLearnSkills = copy
    }
    
    func saveProfile(fullName: String, phoneNumber: String) {
        let user = User(
            fullName: fullName,
            phoneNumber: phoneNumber,
            skillsToTeach: Array(selectedTeachSkills),
            skillsToLearn: Array(selectedLearnSkills),
            experienceLevel: experienceLevel.rawValue,
            location: isLocationEnabled ? location : "",
            bio: bio,
            profileImageURL: ""
        )
        
        isLoading = true
        
        Task {
            // 1. Cache locally for zero-latency profile reads
            PersistenceService.shared.saveUser(user)

            // 2. Persist skill profile to Firestore so it appears in Discover / MatchProfiles
            do {
                try await FirebaseDataService.shared.saveUser(user)
            } catch {
                print("[SkillSetup] Firestore save failed: \(error.localizedDescription)")
            }

            // 3. Seed all Firestore collections for this user (sessions, courses, etc.)
            await DataSeeder.shared.seedAll()

            // 4. Mark as logged in — RootCoordinatorView switches to MainTabView
            UserDefaults.standard.set(true, forKey: "skillspryng.isLoggedIn")
            self.isSetupComplete = true
            self.isLoading = false
        }
    }
}
