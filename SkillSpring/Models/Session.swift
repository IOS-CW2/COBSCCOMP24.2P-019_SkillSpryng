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
}
