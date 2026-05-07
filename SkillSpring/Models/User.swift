import Foundation
import FirebaseFirestore

/// Primary user document stored in Firestore at: users/{uid}
///
/// Contains all user account data including identity, skills, profile info,
/// wallet balance, subscription status, and engagement metrics.
struct User: Identifiable, Codable {
    var id: String?

    // MARK: - Identity
    var fullName: String
    var email: String = ""
    var phoneNumber: String = ""

    // MARK: - Skills & Expertise
    var skillsToTeach: [String] = []
    var skillsToLearn: [String] = []
    var experienceLevel: String = ""

    // MARK: - Profile Information
    var location: String = ""
    var bio: String = ""
    /// URL pointing to the image stored in Firebase Storage.
    var profileImageURL: String = ""
    var role: String = "Member"
    var level: Int = 1

    // MARK: - Engagement Statistics
    var karmaPoints: Int = 0
    var sessionsCount: Int = 0
    var rating: Double = 0.0
    var awardsCount: Int = 0

    // MARK: - Wallet & Credits
    /// User's SKP (SkillSpryng Points) balance. Starts at 500.
    var walletBalance: Int = 500

    // MARK: - Premium Subscription
    var isPremium: Bool = false
    /// Date when Premium/Pro subscription expires.
    var proExpiryDate: Date?

    // MARK: - Accessibility & Settings
    var isChildMode: Bool = false
    /// Percentage of profile completion (0-100).
    var profileCompleteness: Int = 0
    /// Days user is available for sessions (e.g., ["Monday", "Wednesday"]).
    var availabilityDays: [String] = []

    // MARK: - Location Tracking
    /// Last known latitude for geofencing and distance calculations.
    var latitude: Double?
    var longitude: Double?

    // MARK: - Timestamps
    var createdAt: Date = Date()
    var lastActiveAt: Date = Date()

    // MARK: - Skill-Specific Metrics
    /// Per-skill credibility scores and teaching statistics.
    var skillStats: [String: SkillMetrics] = [:]

    // MARK: - Convenience Aliases
    /// Alias for phoneNumber to support legacy code.
    var phone: String {
        get { phoneNumber }
        set { phoneNumber = newValue }
    }
    /// Alias for profileImageURL to support legacy code.
    var imageUrl: String {
        get { profileImageURL }
        set { profileImageURL = newValue }
    }
    /// Alias for sessionsCount to support legacy code.
    var totalSessions: Int {
        get { sessionsCount }
        set { sessionsCount = newValue }
    }
    /// Alias for isPremium to support legacy code.
    var isPro: Bool {
        get { isPremium }
        set { isPremium = newValue }
    }

    // MARK: - Codable (exclude computed aliases)
    enum CodingKeys: String, CodingKey {
        case id, fullName, email, phoneNumber
        case skillsToTeach, skillsToLearn, experienceLevel
        case location, bio, profileImageURL, role, level
        case karmaPoints, sessionsCount, rating, awardsCount
        case walletBalance, isPremium, proExpiryDate
        case isChildMode, profileCompleteness, availabilityDays
        case latitude, longitude, createdAt, lastActiveAt, skillStats
    }
}

/// Credibility and performance metrics for a specific skill.
/// Tracks how well a user teaches or learns a particular skill.
struct SkillMetrics: Codable {
    /// Score based on student feedback and teaching performance.
    var credibilityScore: Int
    /// Number of students the user has taught this skill to.
    var studentsTaught: Int
    /// Average rating from students for this skill.
    var rating: Double
    /// Proficiency level (e.g., "EXPERT", "PRO", "BEGINNER").
    var level: String
}
