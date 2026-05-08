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
    let instructorId: String?  // Added to link reviews to instructor profile
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

    init(
        id: String = UUID().uuidString,
        title: String,
        instructorName: String,
        instructorRole: String,
        instructorId: String? = nil,
        date: String,
        time: String,
        duration: String,
        location: String? = nil,
        distance: String? = nil,
        timeRemaining: String? = nil,
        status: SessionStatus,
        type: SessionType,
        category: String,
        rating: Int? = nil,
        notes: String? = nil,
        creditsEarned: Int? = nil,
        matchPercentage: Int? = 98,
        recordingAvailable: Bool = false,
        recordingDuration: String? = nil,
        lessonCount: Int? = nil,
        calendarEventId: String? = nil,
        scheduledAt: Date = Date(),
        createdAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.instructorName = instructorName
        self.instructorRole = instructorRole
        self.instructorId = instructorId
        self.date = date
        self.time = time
        self.duration = duration
        self.location = location
        self.distance = distance
        self.timeRemaining = timeRemaining
        self.status = status
        self.type = type
        self.category = category
        self.rating = rating
        self.notes = notes
        self.creditsEarned = creditsEarned
        self.matchPercentage = matchPercentage
        self.recordingAvailable = recordingAvailable
        self.recordingDuration = recordingDuration
        self.lessonCount = lessonCount
        self.calendarEventId = calendarEventId
        self.scheduledAt = scheduledAt
        self.createdAt = createdAt
        self.completedAt = completedAt
    }
}
