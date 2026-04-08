import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    var id: String?
    var fullName: String
    var phoneNumber: String
    var skillsToTeach: [String] = []
    var skillsToLearn: [String] = []
    var experienceLevel: String = ""
    var location: String = ""
    var bio: String = ""
    var profileImageURL: String = ""
    var createdAt: Date = Date()
    
    // New fields for Profile Tab
    var role: String = "Member"
    var level: Int = 1
    var karmaPoints: Int = 0
    var sessionsCount: Int = 0
    var rating: Double = 0.0
    var awardsCount: Int = 0
    var walletBalance: Int = 0
    var isPro: Bool = false
    var isChildMode: Bool = false
    var profileCompleteness: Int = 0
}
