import Foundation

struct UserReview: Identifiable {
    let id = UUID()
    let reviewerName: String
    let rating: Int
    let comment: String
    let reviewerImageUrl: String
}
