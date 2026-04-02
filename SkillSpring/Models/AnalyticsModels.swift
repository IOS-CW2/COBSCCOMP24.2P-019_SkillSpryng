import Foundation

// MARK: - AnalyticsData
// Top-level container for all data shown on the Learning Pulse (Analytics) dashboard.
struct AnalyticsData {
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
struct GrowthPoint: Identifiable {
    let id = UUID()
    let day: String
    let value: Double
}

// MARK: - SkillProgress
// Represents a user's progress in a specific skill (shown as a progress bar).
struct SkillProgress: Identifiable {
    let id = UUID()
    let name: String
    let percentage: Double
    let level: String
}
