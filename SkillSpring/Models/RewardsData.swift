import Foundation

struct MasteryPoints: Codable {
    var total: Int
    var level: Int
    var progressTowardsNextLevel: Double // 0.0 to 1.0
}

struct LeaderboardEntry: Identifiable, Codable {
    var id: String = UUID().uuidString
    var fullName: String
    var points: Int
    var rank: Int
    var avatarUrl: String
    var isCurrentUser: Bool = false
    var weeklyChange: Int? // e.g., +3 positions
}

struct Milestone: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var progress: Int
    var total: Int
    var iconName: String
}

struct RewardBadge: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var iconName: String
    var colorHex: String
    var dateEarned: Date?
}

struct CreditPack: Identifiable, Codable {
    var id: String = UUID().uuidString
    var amount: Int
    var bonusAmount: Int?
    var price: String
    var isBestValue: Bool = false
}

struct SkillMission: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var rewardAmount: Int
    var status: MissionStatus
}

enum MissionStatus: String, Codable {
    case available, inProgress, completed
}
