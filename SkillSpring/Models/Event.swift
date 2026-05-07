import Foundation

/// Represents a live event or workshop that users can attend.
/// Events can be free or paid, in-person or online.
struct Event: Identifiable, Codable {
    var id: String = UUID().uuidString
    let title: String
    let instructor: String
    let date: String
    let time: String
    let location: String
    let imageUrl: String
    let category: String
    let attendanceCount: String
    let isFree: Bool
    /// Number of open spots remaining. Nil if unlimited.
    let spotsLeft: Int?
}
