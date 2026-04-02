import Foundation

// MARK: - RecommendedSkill
// Represents a skill listing shown on the Discover (Home) screen.
struct RecommendedSkill: Identifiable {
    let id = UUID()
    let title: String
    let instructor: String
    let price: String
    let rating: Double
    let imageName: String
    let category: String
    let isTopRated: Bool
    let instructorImage: String?
}
