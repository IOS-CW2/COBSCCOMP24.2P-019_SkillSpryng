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
}
