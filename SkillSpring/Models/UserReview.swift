import Foundation

struct UserReview: Identifiable, Codable {
    var id: String = UUID().uuidString
    let reviewerName: String
    let rating: Int
    let comment: String
    let reviewerImageUrl: String
}
