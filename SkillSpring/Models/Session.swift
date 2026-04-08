import Foundation

enum SessionStatus: String {
    case upcoming = "UPCOMING"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"
}

enum SessionType: String {
    case online = "ONLINE"
    case inPerson = "IN-PERSON"
}

struct Session: Identifiable {
    let id = UUID()
    let title: String
    let instructorName: String
    let instructorRole: String
    let date: String
    let time: String
    let duration: String
    let location: String?
    let distance: String?
    let timeRemaining: String? // e.g. "In 2 hours"
    let status: SessionStatus
    let type: SessionType
    let category: String // e.g. "Digital Workshop", "1-on-1 Mentorship"
    let rating: Int?
}
