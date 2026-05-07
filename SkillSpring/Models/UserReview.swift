import Foundation

/// A review or testimonial left by one user about another.
/// Typically shown on user profiles and match cards to build trust.
struct UserReview: Identifiable, Codable {
    var id: String = UUID().uuidString
    let reviewerName: String
    /// Star rating (1-5) given by the reviewer.
    let rating: Int
    /// The review text/comment.
    let comment: String
    let reviewerImageUrl: String
}
