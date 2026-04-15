import Foundation
import FirebaseFirestore

// MARK: - User
// Primary user document stored at: users/{uid}

struct User: Identifiable, Codable {
    var id: String?

    // Identity
    var fullName: String
    var email: String = ""
    var phoneNumber: String = ""

    // Skills
    var skillsToTeach: [String] = []
    var skillsToLearn: [String] = []
    var experienceLevel: String = ""

    // Profile
    var location: String = ""
    var bio: String = ""
    var profileImageURL: String = ""       // Firebase Storage URL
    var role: String = "Member"
    var level: Int = 1

    // Stats
    var karmaPoints: Int = 0
    var sessionsCount: Int = 0
    var rating: Double = 0.0
    var awardsCount: Int = 0

    // Wallet
    var walletBalance: Int = 500           // Starter balance (SKP)

    // Subscription
    var isPremium: Bool = false
    var proExpiryDate: Date?

    // Settings
    var isChildMode: Bool = false
    var profileCompleteness: Int = 0
    var availabilityDays: [String] = []

    // Geolocation (last known)
    var latitude: Double?
    var longitude: Double?

    // Timestamps
    var createdAt: Date = Date()
    var lastActiveAt: Date = Date()

    // Skill-specific credibility stats
    var skillStats: [String: SkillMetrics] = [:]

    // MARK: - Convenience aliases
    var phone: String {
        get { phoneNumber }
        set { phoneNumber = newValue }
    }
    var imageUrl: String {
        get { profileImageURL }
        set { profileImageURL = newValue }
    }
    var totalSessions: Int {
        get { sessionsCount }
        set { sessionsCount = newValue }
    }
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

// MARK: - SkillMetrics
struct SkillMetrics: Codable {
    var credibilityScore: Int
    var studentsTaught: Int
    var rating: Double
    var level: String   // e.g., "EXPERT", "PRO"
}
