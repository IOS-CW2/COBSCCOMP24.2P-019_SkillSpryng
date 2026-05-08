// LearningViewModelTests.swift
// SkillSpryng — LearningViewModel Unit Tests
//
// Tests `filteredFeatured` (category filter), `happeningSoonEvent` (first event),
// and tab/category state by injecting fixtures directly into published arrays.
// No Firestore connection required.
//
// Pattern: Arrange → Act → Assert (AAA)

import XCTest
@testable import SkillSpring

@MainActor
final class LearningViewModelTests: XCTestCase {

    // MARK: - System Under Test
    private var sut: LearningViewModel!

    // MARK: - Fixtures

    private func makeCourse(title: String, category: String) -> Course {
        Course(
            title: title,
            instructor: "Test Instructor",
            rating: 4.5,
            imageName: "test_image",
            category: category,
            price: "100 SKP",
            studentsCount: "50",
            progress: nil,
            instructorImage: "instructor1"
        )
    }

    private func makeEvent(title: String) -> Event {
        Event(
            title: title,
            instructor: "Event Host",
            date: "May 10, 2026",
            time: "6:00 PM",
            location: "Colombo",
            imageUrl: "event_ui",
            category: "Workshop",
            attendanceCount: "12 attending",
            isFree: true,
            spotsLeft: 5
        )
    }

    override func setUp() {
        super.setUp()
        sut = LearningViewModel()
        // Inject deterministic fixtures
        sut.featuredCourses = [
            makeCourse(title: "iOS Dev",       category: "Coding"),
            makeCourse(title: "Figma Pro",     category: "Design"),
            makeCourse(title: "React Native",  category: "Coding"),
            makeCourse(title: "Music Theory",  category: "Music")
        ]
        sut.upcomingEvents = []
        sut.selectedCategory = "All"
        sut.selectedTab = "Courses"
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - filteredFeatured: All Category

    func test_filteredFeatured_withAllCategory_returnsEverything() {
        sut.selectedCategory = "All"
        XCTAssertEqual(sut.filteredFeatured.count, 4,
                       "Selecting 'All' must return all featured courses.")
    }

    // MARK: - filteredFeatured: Specific Category

    func test_filteredFeatured_withCodingCategory_returnsOnlyCodingCourses() {
        sut.selectedCategory = "Coding"
        XCTAssertEqual(sut.filteredFeatured.count, 2)
        XCTAssertTrue(sut.filteredFeatured.allSatisfy { $0.category == "Coding" })
    }

    func test_filteredFeatured_withDesignCategory_returnsOnlyDesign() {
        sut.selectedCategory = "Design"
        XCTAssertEqual(sut.filteredFeatured.count, 1)
        XCTAssertEqual(sut.filteredFeatured.first?.title, "Figma Pro")
    }

    func test_filteredFeatured_withCategoryThatMatchesNone_returnsEmpty() {
        sut.selectedCategory = "Languages"
        XCTAssertTrue(sut.filteredFeatured.isEmpty,
                      "No 'Languages' courses in fixtures — result must be empty.")
    }

    func test_filteredFeatured_categoryIsCaseInsensitive() {
        sut.selectedCategory = "coding"
        XCTAssertEqual(sut.filteredFeatured.count, 2,
                       "filteredFeatured must use case-insensitive matching.")
    }

    // MARK: - happeningSoonEvent

    func test_happeningSoonEvent_returnsFirstUpcomingEvent() {
        // Arrange
        let first  = makeEvent(title: "Sketch Workshop")
        let second = makeEvent(title: "AI Design Talks")
        sut.upcomingEvents = [first, second]
        // Act + Assert
        XCTAssertEqual(sut.happeningSoonEvent?.title, "Sketch Workshop",
                       "happeningSoonEvent must return the first element of upcomingEvents.")
    }

    func test_happeningSoonEvent_isNilWhenNoEvents() {
        sut.upcomingEvents = []
        XCTAssertNil(sut.happeningSoonEvent,
                     "happeningSoonEvent must be nil when upcomingEvents is empty.")
    }

    func test_happeningSoonEvent_withSingleEvent_returnsThatEvent() {
        let only = makeEvent(title: "Solo Workshop")
        sut.upcomingEvents = [only]
        XCTAssertEqual(sut.happeningSoonEvent?.title, "Solo Workshop")
    }

    // MARK: - Tab / Category State

    func test_selectedTab_defaultIsCourses() {
        let freshVM = LearningViewModel()
        XCTAssertEqual(freshVM.selectedTab, "Courses",
                       "Default selected tab must be 'Courses'.")
    }

    func test_selectedCategory_defaultIsAll() {
        let freshVM = LearningViewModel()
        XCTAssertEqual(freshVM.selectedCategory, "All",
                       "Default selected category must be 'All'.")
    }

    func test_categories_containsAll() {
        XCTAssertTrue(sut.categories.contains("All"),
                      "categories must include 'All' as the reset option.")
    }

    func test_categories_countIsCorrect() {
        XCTAssertEqual(sut.categories.count, 6,
                       "There must be exactly 6 category options.")
    }

    func test_selectedTab_canBeChangedToEvents() {
        sut.selectedTab = "Events"
        XCTAssertEqual(sut.selectedTab, "Events")
    }

    func test_selectedCategory_canBeChangedAndReset() {
        sut.selectedCategory = "Music"
        XCTAssertEqual(sut.filteredFeatured.count, 1)

        sut.selectedCategory = "All"
        XCTAssertEqual(sut.filteredFeatured.count, 4)
    }

    // MARK: - Course Model

    func test_course_progressNil_representsNotStarted() {
        let course = makeCourse(title: "New Course", category: "Coding")
        XCTAssertNil(course.progress,
                     "A course with nil progress has not been started by the user.")
    }

    func test_course_progressInValidRange_whenSet() {
        var course = makeCourse(title: "In Progress", category: "Design")
        course = Course(
            title: course.title, instructor: course.instructor,
            rating: course.rating, imageName: course.imageName,
            category: course.category, price: course.price,
            studentsCount: course.studentsCount, progress: 0.4,
            instructorImage: course.instructorImage
        )
        XCTAssertTrue((0.0...1.0).contains(course.progress ?? -1),
                      "Course progress must be in the 0.0–1.0 range when set.")
    }

    // MARK: - Event Model

    func test_event_isFree_flagPreserved() {
        let freeEvent = makeEvent(title: "Free Workshop")
        XCTAssertTrue(freeEvent.isFree)
    }

    func test_event_spotsLeft_canBeNilForUnlimited() {
        let event = Event(
            title: "Big Conference",
            instructor: "Host",
            date: "Jun 1, 2026",
            time: "9:00 AM",
            location: "Colombo",
            imageUrl: "event_ui",
            category: "Conference",
            attendanceCount: "200 attending",
            isFree: false,
            spotsLeft: nil
        )
        XCTAssertNil(event.spotsLeft,
                     "spotsLeft == nil indicates unlimited capacity.")
    }
}
