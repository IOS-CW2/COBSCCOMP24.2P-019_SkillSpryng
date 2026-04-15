import Foundation

enum SessionStatus: String, Codable {
    case upcoming  = "UPCOMING"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"
}

enum SessionType: String, Codable {
    case online   = "ONLINE"
    case inPerson = "IN-PERSON"
}

struct Session: Identifiable, Codable {
    var id: String = UUID().uuidString
    let title: String
    let instructorName: String
    let instructorRole: String
    let date: String
    let time: String
    let duration: String
    let location: String?
    let distance: String?
    let timeRemaining: String?
    let status: SessionStatus
    let type: SessionType
    let category: String
    let rating: Int?

    // Detailed fields
    var notes: String?
    var creditsEarned: Int?
    var matchPercentage: Int? = 98
    var recordingAvailable: Bool = false
    var recordingDuration: String?
    var lessonCount: Int?
    var calendarEventId: String?

    // Timestamps for Firestore ordering & status tracking
    var scheduledAt: Date = Date()
    var createdAt: Date = Date()
    var completedAt: Date?
}
