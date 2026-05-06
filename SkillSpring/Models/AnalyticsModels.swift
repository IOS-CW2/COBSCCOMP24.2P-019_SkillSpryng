import Foundation

// MARK: - AnalyticsData
// Top-level container for all data shown on the Learning Pulse (Analytics) dashboard.
struct AnalyticsData: Codable {
    let streakDays: Int
    let sessionsCount: Int
    let focusHours: Double
    let skillsPro: Int
    let karmaPoints: Int
    let growthHistory: [GrowthPoint]
    let skillProgress: [SkillProgress]
}

// MARK: - GrowthPoint
// A single data point in the Growth Trajectory graph (one per day).
struct GrowthPoint: Identifiable, Codable {
    var id: String = UUID().uuidString
    let day: String
    let value: Double
}

// MARK: - SkillProgress
// Represents a user's progress in a specific skill (shown as a progress bar).
struct SkillProgress: Identifiable, Codable {
    var id: String = UUID().uuidString
    let name: String
    let percentage: Double
    let level: String
}

// MARK: - MatchRequest
enum MatchRequestStatus: String, Codable {
    case pending   = "pending"
    case accepted  = "accepted"
    case declined  = "declined"
    case cancelled = "cancelled"
}

struct MatchRequest: Identifiable, Codable {
    var id: String = UUID().uuidString
    var fromUserId: String
    var toUserId: String
    var fromUserName: String
    var toUserName: String
    var skillOffered: String
    var skillWanted: String
    var status: MatchRequestStatus = .pending
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var message: String = ""
    // Scheduling metadata written by BookingViewModel at request creation
    var scheduledDate: Date? = nil
    var scheduledTime: String? = nil
    var durationMinutes: Int? = nil
    var isOnline: Bool? = nil
}

// MARK: - CreditTransaction
enum TransactionType: String, Codable {
    case sessionPayment  = "session_payment"
    case sessionEarning  = "session_earning"
    case creditPurchase  = "credit_purchase"
    case refund          = "refund"
    case rewardBonus     = "reward_bonus"
}

struct CreditTransaction: Identifiable, Codable {
    var id: String = UUID().uuidString
    var amount: Int
    var type: TransactionType
    var description: String
    var balanceAfter: Int
    var referenceId: String?
    var createdAt: Date = Date()
}

// MARK: - AppNotification
enum AppNotificationType: String, Codable {
    case matchRequest      = "match_request"
    case sessionReminder   = "session_reminder"
    case sessionConfirmed  = "session_confirmed"
    case sessionCancelled  = "session_cancelled"
    case messageReceived   = "message_received"
    case rewardEarned      = "reward_earned"
    case systemAlert       = "system_alert"
}

struct AppNotification: Identifiable, Codable {
    var id: String = UUID().uuidString
    var type: AppNotificationType
    var title: String
    var body: String
    var isRead: Bool = false
    var referenceId: String?
    var createdAt: Date = Date()
}
