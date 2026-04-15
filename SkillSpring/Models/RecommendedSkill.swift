import Foundation

// MARK: - RecommendedSkill
// Represents a skill listing shown on the Discover (Home) screen.
struct RecommendedSkill: Identifiable, Codable {
    var id: String = UUID().uuidString
    let title: String
    let instructor: String
    let price: String
    let rating: Double
    let imageName: String
    let category: String
    let isTopRated: Bool
    let instructorImage: String?
}
