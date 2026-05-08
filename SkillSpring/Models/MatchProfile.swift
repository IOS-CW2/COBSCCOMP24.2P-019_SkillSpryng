import Foundation

/// The current status of a skill match between two users.
enum MatchStatus: String, Codable {
    case suggested = "suggested"
    case requestIncoming = "requestIncoming"
    case requestSent = "requestSent"
    case active = "active"
    case archived = "archived"
}

/// A user profile shown in the Discover/Matches section.
/// Contains their skills, ratings, reviews, and match compatibility score.
struct MatchProfile: Identifiable, Codable {
    var id: String = UUID().uuidString
    let fullName: String
    let role: String
    let location: String
    /// Distance from the current user (e.g., "2.3 km").
    let distance: String
    /// Compatibility percentage (0-100) based on skill overlap and ratings.
    let matchPercentage: Int
    let bio: String
    let skillsToTeach: [String]
    let skillsToLearn: [String]
    let imageUrl: String
    /// True if the user is currently active in the app.
    let onlineStatus: Bool
    let city: String
    let sessionsCount: Int
    let rating: Double
    /// Estimated response time (e.g., "< 1 hour").
    let responseTime: String
    /// Days and times when the user is available.
    let availability: [String]
    let reviews: [UserReview]
    /// Current match status between the logged-in user and this profile.
    var status: MatchStatus = .suggested
    /// Hourly rate in SKP (SkillSpryng Credits).
    var hourlyRate: Int = 120
}
