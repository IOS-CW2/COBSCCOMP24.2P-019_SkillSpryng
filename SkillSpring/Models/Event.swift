import Foundation

struct Event: Identifiable {
    let id = UUID()
    let title: String
    let instructor: String
    let date: String
    let time: String
    let location: String
    let imageUrl: String
    let category: String
    let attendanceCount: String
    let isFree: Bool
    let spotsLeft: Int?
}
