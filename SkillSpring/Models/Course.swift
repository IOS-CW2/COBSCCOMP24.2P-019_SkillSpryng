import Foundation

struct Course: Identifiable, Codable {
    var id: String = UUID().uuidString
    let title: String
    let instructor: String
    let rating: Double
    let imageName: String
    let category: String
    let price: String
    let studentsCount: String
    let progress: Double? // 0.0 to 1.0, nil if not started
    let instructorImage: String
}
