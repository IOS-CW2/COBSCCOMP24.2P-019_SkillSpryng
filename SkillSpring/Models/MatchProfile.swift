import Foundation

enum MatchStatus: String, Codable {
    case suggested = "suggested"
    case requestIncoming = "requestIncoming"
    case requestSent = "requestSent"
    case active = "active"
    case archived = "archived"
}

struct MatchProfile: Identifiable, Codable {
    var id: String = UUID().uuidString
    let fullName: String
    let role: String
    let location: String
    let distance: String
    let matchPercentage: Int
    let bio: String
    let skillsToTeach: [String]
    let skillsToLearn: [String]
    let imageUrl: String
    let onlineStatus: Bool
    let city: String
    let sessionsCount: Int
    let rating: Double
    let responseTime: String
    let availability: [String]
    let reviews: [UserReview]
    var status: MatchStatus = .suggested
    var hourlyRate: Int = 120 // Default rate in SKP
}
