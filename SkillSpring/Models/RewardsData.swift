import Foundation

/// Tracks a user's mastery points and level progression.
/// Points accumulate towards unlocking higher skill levels.
struct MasteryPoints: Codable {
    var total: Int
    var level: Int
    /// Progress towards the next level (0.0 to 1.0).
    var progressTowardsNextLevel: Double
}

/// Represents a user's position on the leaderboard.
/// Shows rank, points, and weekly movement.
struct LeaderboardEntry: Identifiable, Codable {
    var id: String = UUID().uuidString
    var fullName: String
    var points: Int
    var rank: Int
    var avatarUrl: String
    /// True if this entry is the logged-in user.
    var isCurrentUser: Bool = false
    /// Weekly rank change (e.g., +3 means moved up 3 positions).
    var weeklyChange: Int?
}

/// A milestone achievement the user is working towards.
/// Can be skill-based (e.g., teach 10 sessions) or general (e.g., 100 points).
struct Milestone: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    /// Current progress towards the milestone.
    var progress: Int
    /// Total required to complete the milestone.
    var total: Int
    var iconName: String
}

/// A badge earned by the user for achievements or milestones.
struct RewardBadge: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var iconName: String
    var colorHex: String
    /// Date the badge was earned. Nil if not yet unlocked.
    var dateEarned: Date?
}

/// A credit pack available for purchase in the rewards shop.
/// Larger packs may include bonus credits.
struct CreditPack: Identifiable, Codable {
    var id: String = UUID().uuidString
    var amount: Int
    /// Extra credits added as a bonus for purchasing this pack.
    var bonusAmount: Int?
    var price: String
    /// Whether this pack is marked as the best value option.
    var isBestValue: Bool = false
}

/// A mission or task the user can complete for rewards.
struct SkillMission: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    /// Credits earned when the mission is completed.
    var rewardAmount: Int
    var status: MissionStatus
}

/// The current state of a skill mission.
enum MissionStatus: String, Codable {
    case available
    case inProgress
    case completed
}
