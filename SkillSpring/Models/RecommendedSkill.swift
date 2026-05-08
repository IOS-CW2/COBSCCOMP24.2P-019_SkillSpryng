import Foundation

/// Represents a skill recommendation displayed on the Discover (Home) screen.
/// Shows popular and relevant skills that users can learn from instructors.
struct RecommendedSkill: Identifiable, Codable {
    var id: String = UUID().uuidString
    let title: String
    let instructor: String
    let price: String
    let rating: Double
    let imageName: String
    let category: String
    /// Whether this skill has a "Top Rated" badge.
    let isTopRated: Bool
    let instructorImage: String?
}
