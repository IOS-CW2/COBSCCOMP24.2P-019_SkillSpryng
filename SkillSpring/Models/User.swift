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
}
