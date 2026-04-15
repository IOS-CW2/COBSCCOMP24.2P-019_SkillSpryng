import Foundation

// MARK: - MockDataProvider
// The singleton is defined here. Domain-specific data is split into
// separate extension files (MockDataProvider+*.swift) for maintainability.

class MockDataProvider {
    static let shared = MockDataProvider()

    // MARK: - Current User
    var currentUser = User(
        fullName: "Alex Rivera",
        phoneNumber: "+1 234 567 890",
        skillsToTeach: ["UI Design", "Brand Strategy", "React Native"],
        skillsToLearn: ["Surfing", "Pottery", "Public Speaking"],
        experienceLevel: "Expert",
        location: "San Francisco, CA",
        bio: "Adrian is an incredible mentor. He doesn't just teach craft, he teaches the mindset of a successful lead designer.",
        profileImageURL: "instructor2",
        role: "Pro Instructor",
        level: 4,
        karmaPoints: 4850,
        sessionsCount: 128,
        rating: 4.9,
        awardsCount: 12,
        walletBalance: 200,
        isPro: false,
        isChildMode: false,
        profileCompleteness: 85,
        skillStats: [
            "Creative Design": SkillMetrics(credibilityScore: 85, studentsTaught: 12, rating: 4.9, level: "EXPERT"),
            "UI Engineering": SkillMetrics(credibilityScore: 62, studentsTaught: 24, rating: 5.0, level: "PRO")
        ]
    )
}
