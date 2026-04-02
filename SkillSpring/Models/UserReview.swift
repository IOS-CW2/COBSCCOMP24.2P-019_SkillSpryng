import Foundation

// MARK: - UserReview
// Represents a review left on a mentor's profile by a past student.
struct UserReview: Identifiable {
    let id = UUID()
    let userName: String
    let rating: Int
    let comment: String
    let userImageUrl: String
}
