import Foundation

/// The current state of a learning session.
enum SessionStatus: String, Codable {
    case upcoming  = "UPCOMING"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"
}

/// Whether a session is conducted online or in person.
enum SessionType: String, Codable {
    case online   = "ONLINE"
    case inPerson = "IN-PERSON"
}

/// Represents a learning session between two users.
/// Sessions can be part of a course, a one-off booking, or part of a match agreement.
struct Session: Identifiable, Codable {
    var id: String = UUID().uuidString
    let title: String
    let instructorName: String
    let instructorRole: String
    let date: String
    let time: String
    let duration: String
    let location: String?
    /// Distance from current user (for in-person sessions).
    let distance: String?
    /// Time until session starts (e.g., "2 hours").
    let timeRemaining: String?
    let status: SessionStatus
    let type: SessionType
    let category: String
    /// Numeric rating if the session has been reviewed.
    let rating: Int?

    // Additional details
    var notes: String?
    /// Credits earned or spent on this session.
    var creditsEarned: Int?
    /// Skill match percentage between instructor and student.
    var matchPercentage: Int? = 98
    /// Whether a recording is available for this session.
    var recordingAvailable: Bool = false
    var recordingDuration: String?
    /// Part of a series. Nil if standalone.
    var lessonCount: Int?
    /// Reference to calendar event for easy access.
    var calendarEventId: String?

    // Timestamps for ordering and tracking
    var scheduledAt: Date = Date()
    var createdAt: Date = Date()
    var completedAt: Date?
}
