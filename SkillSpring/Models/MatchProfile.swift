import Foundation

enum MatchStatus {
    case suggested
    case requestIncoming
    case requestSent
    case active
    case archived
}

struct MatchProfile: Identifiable {
    let id = UUID()
    let fullName: String
    let role: String
    let location: String
    let distance: String
    let matchPercentage: Int
    let bio: String
    let canTeach: [String]
    let wantsToLearn: [String]
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
