import Foundation

/// Container for all analytics data displayed on the Learning Pulse dashboard.
/// Includes user streaks, session history, focus time, and skill progress tracking.
struct AnalyticsData: Codable {
    let streakDays: Int
    let sessionsCount: Int
    let focusHours: Double
    let skillsPro: Int
    let karmaPoints: Int
    let growthHistory: [GrowthPoint]
    let skillProgress: [SkillProgress]
}

/// A single data point in the Growth Trajectory graph.
/// Each point represents one day's activity level or progress.
struct GrowthPoint: Identifiable, Codable {
    var id: String = UUID().uuidString
    let day: String
    let value: Double
}

/// Tracks a user's progress in a specific skill.
/// Displayed as progress bars showing how close they are to proficiency in each skill.
struct SkillProgress: Identifiable, Codable {
    var id: String = UUID().uuidString
    let name: String
    let percentage: Double
    let level: String
}

/// Status of a skill exchange request between two users.
enum MatchRequestStatus: String, Codable {
    case pending   = "pending"
    case accepted  = "accepted"
    case declined  = "declined"
    case cancelled = "cancelled"
}

/// Represents a request from one user to exchange skills with another.
/// Includes scheduling details for the planned session.
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
    /// Session details captured at request creation by BookingViewModel
    var scheduledDate: Date? = nil
    var scheduledTime: String? = nil
    var durationMinutes: Int? = nil
    var isOnline: Bool? = nil
}

/// Types of transactions in the user's wallet.
enum TransactionType: String, Codable {
    case sessionPayment  = "session_payment"
    case sessionEarning  = "session_earning"
    case creditPurchase  = "credit_purchase"
    case refund          = "refund"
    case rewardBonus     = "reward_bonus"
}

/// Records a credit transaction in the user's wallet history.
/// Used for audit trail and balance reconciliation.
struct CreditTransaction: Identifiable, Codable {
    var id: String = UUID().uuidString
    var amount: Int
    var type: TransactionType
    var description: String
    var balanceAfter: Int
    var referenceId: String?
    var createdAt: Date = Date()
}

/// Types of in-app notifications users can receive.
enum AppNotificationType: String, Codable {
    case matchRequest      = "match_request"
    case sessionReminder   = "session_reminder"
    case sessionConfirmed  = "session_confirmed"
    case sessionCancelled  = "session_cancelled"
    case messageReceived   = "message_received"
    case rewardEarned      = "reward_earned"
    case systemAlert       = "system_alert"
}

/// Notification that gets delivered to the user.
/// Tracks read status and references related objects.
struct AppNotification: Identifiable, Codable {
    var id: String = UUID().uuidString
    var type: AppNotificationType
    var title: String
    var body: String
    var isRead: Bool = false
    var referenceId: String?
    var createdAt: Date = Date()
}
