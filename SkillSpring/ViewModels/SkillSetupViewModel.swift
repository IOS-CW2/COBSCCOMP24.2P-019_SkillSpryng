import Foundation
import Combine
import UIKit

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
    
    init(firebaseService: FirebaseService = FirebaseManager.shared) {
        self.firebaseService = firebaseService
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
        if selectedTeachSkills.contains(skill) {
            selectedTeachSkills.remove(skill)
        } else {
            selectedTeachSkills.insert(skill)
        }
    }
    
    func toggleLearnSkill(_ skill: String) {
        if selectedLearnSkills.contains(skill) {
            selectedLearnSkills.remove(skill)
        } else {
            selectedLearnSkills.insert(skill)
        }
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
            profileImageURL: "" // This would be the URL from storage in a real app
        )
        
        isLoading = true
        
        Task {
            // Temporarily mocked to bypass for UI testing
            self.isSetupComplete = true
            self.isLoading = false
        }
    }
}
