import XCTest
import CoreData
@testable import SkillSpring

final class PersistenceTests: XCTestCase {
    
    var service: PersistenceService!
    
    override func setUp() {
        super.setUp()
        let controller = PersistenceController(inMemory: true)
        service = PersistenceService(context: controller.container.viewContext)
    }
    
    override func tearDown() {
        service = nil
        super.tearDown()
    }
    
    func testSaveAndFetchUser() {
        // 1. Create a mock user
        let mockUser = User(
            id: "test-uid-123",
            fullName: "Test User",
            phoneNumber: "+1555000111",
            skillsToTeach: ["Swift", "Core Data"],
            skillsToLearn: ["Yoga"],
            experienceLevel: "Expert",
            location: "Test City",
            bio: "This is a test bio",
            profileImageURL: "test-url"
        )
        
        // 2. Save to PersistenceService
        service.saveUser(mockUser)
        
        // 3. Fetch back
        let fetchedUser = service.fetchUser()
        
        // 4. Verify fields
        XCTAssertNotNil(fetchedUser)
        XCTAssertEqual(fetchedUser?.id, mockUser.id)
        XCTAssertEqual(fetchedUser?.fullName, mockUser.fullName)
        XCTAssertEqual(fetchedUser?.skillsToTeach, mockUser.skillsToTeach)
        XCTAssertEqual(fetchedUser?.skillsToLearn, mockUser.skillsToLearn)
        XCTAssertEqual(fetchedUser?.experienceLevel, mockUser.experienceLevel)
    }
    
    func testClearCache() {
        // 1. Save a user
        let mockUser = User(fullName: "To Be Deleted", phoneNumber: "000")
        service.saveUser(mockUser)
        
        // 2. Verify it exists
        XCTAssertNotNil(service.fetchUser())
        
        // 3. Clear cache
        service.clearCache()
        
        // 4. Verify it's gone
        XCTAssertNil(service.fetchUser())
    }
    
    func testUpdateExistingUser() {
        // 1. Save initial user
        let user1 = User(fullName: "Initial Name", phoneNumber: "111")
        service.saveUser(user1)
        
        // 2. Update same user (Core Data should update the single record)
        let user2 = User(fullName: "Updated Name", phoneNumber: "111")
        service.saveUser(user2)
        
        // 3. Fetch and verify
        let fetched = service.fetchUser()
        XCTAssertEqual(fetched?.fullName, "Updated Name")
    }

    // MARK: - Session Cache Tests

    func testSaveAndFetchSession() {
        // Arrange
        let session = Session(
            title: "Swift Mentoring",
            instructorName: "Ada Lovelace",
            instructorRole: "iOS Expert",
            date: "May 8, 2026",
            time: "10:00 AM",
            duration: "60 min",
            location: nil,
            distance: nil,
            timeRemaining: "Upcoming",
            status: .upcoming,
            type: .online,
            category: "Coding",
            rating: nil
        )

        // Act
        service.saveSession(session)
        let fetched = service.fetchSessions()

        // Assert
        XCTAssertFalse(fetched.isEmpty, "fetchSessions must return at least one session after save.")
        XCTAssertEqual(fetched.first?.title, "Swift Mentoring")
        XCTAssertEqual(fetched.first?.instructorName, "Ada Lovelace")
        XCTAssertEqual(fetched.first?.status, .upcoming)
        XCTAssertEqual(fetched.first?.type, .online)
    }

    func testClearSessionCache() {
        // Arrange — seed a session
        let session = Session(
            title: "Test Session",
            instructorName: "Instructor",
            instructorRole: "Role",
            date: "May 8, 2026",
            time: "09:00 AM",
            duration: "30 min",
            location: nil,
            distance: nil,
            timeRemaining: nil,
            status: .upcoming,
            type: .online,
            category: "Test",
            rating: nil
        )
        service.saveSession(session)
        XCTAssertFalse(service.fetchSessions().isEmpty, "Session must exist before clear.")

        // Act
        service.clearSessionCache()

        // Assert
        XCTAssertTrue(service.fetchSessions().isEmpty, "Session cache must be empty after clearSessionCache().")
    }

    func testFetchSessionsOrderedByScheduledAt() {
        // Arrange — save two sessions with different scheduledAt
        var early = Session(
            title: "Early Session",
            instructorName: "A", instructorRole: "R",
            date: "May 7, 2026", time: "08:00 AM", duration: "60 min",
            location: nil, distance: nil, timeRemaining: nil,
            status: .upcoming, type: .online, category: "X", rating: nil
        )
        early.scheduledAt = Date(timeIntervalSinceNow: 3600)

        var late = Session(
            title: "Late Session",
            instructorName: "B", instructorRole: "R",
            date: "May 7, 2026", time: "10:00 AM", duration: "60 min",
            location: nil, distance: nil, timeRemaining: nil,
            status: .upcoming, type: .online, category: "X", rating: nil
        )
        late.scheduledAt = Date(timeIntervalSinceNow: 7200)

        service.saveSession(early)
        service.saveSession(late)

        // Act
        let results = service.fetchSessions()

        // Assert — most recent (latest scheduledAt) should come first
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.first?.title, "Late Session",
                       "fetchSessions must return sessions ordered by scheduledAt descending.")
    }
}
