import Foundation
import Combine

@MainActor
class SkillSetupViewModel: ObservableObject {
    @Published var selectedTeachSkills: Set<String> = []
    @Published var selectedLearnSkills: Set<String> = []
    @Published var experienceLevel: ExperienceLevel = .beginner
    @Published var location: String = ""
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isSetupComplete: Bool = false
    
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
            location: location
        )
        
        isLoading = true
        
        Task {
            do {
                try await FirebaseManager.shared.saveUser(user)
                self.isSetupComplete = true
            } catch {
                self.errorMessage = "Failed to save profile: \(error.localizedDescription)"
            }
            self.isLoading = false
        }
    }
}
