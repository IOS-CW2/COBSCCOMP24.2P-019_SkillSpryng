import Foundation

/// Represents a course listing shown in the Learning section.
/// Contains course details, instructor info, and user progress if enrolled.
struct Course: Identifiable, Codable {
    var id: String = UUID().uuidString
    let title: String
    let instructor: String
    let rating: Double
    let imageName: String
    let category: String
    let price: String
    let studentsCount: String
    /// Progress from 0.0 to 1.0. Nil if the user hasn't started this course.
    let progress: Double?
    let instructorImage: String
}
