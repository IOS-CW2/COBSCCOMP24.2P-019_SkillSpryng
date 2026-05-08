// DiscoverViewModelTests.swift
// SkillSpryng — DiscoverViewModel Unit Tests
//
// Tests the `filteredSkills` computed property — the core search + category filter
// logic — by injecting fixture data directly into the published arrays.
// No Firestore connection required.
//
// Pattern: Arrange → Act → Assert (AAA)

import XCTest
@testable import SkillSpring

@MainActor
final class DiscoverViewModelTests: XCTestCase {

    // MARK: - System Under Test
    private var sut: DiscoverViewModel!

    // MARK: - Fixtures

    private func makeSkill(
        title: String,
        instructor: String = "Instructor",
        category: String = "Coding"
    ) -> RecommendedSkill {
        RecommendedSkill(
            title: title,
            instructor: instructor,
            price: "50 SKP",
            rating: 4.5,
            imageName: "test_image",
            category: category,
            isTopRated: false,
            instructorImage: nil
        )
    }

    override func setUp() {
        super.setUp()
        sut = DiscoverViewModel()
        // Inject deterministic fixtures
        sut.recommendedSkills = [
            makeSkill(title: "Swift Basics",   instructor: "Alice", category: "Coding"),
            makeSkill(title: "Figma Design",   instructor: "Bob",   category: "Design"),
            makeSkill(title: "Marketing 101",  instructor: "Carol", category: "Marketing"),
            makeSkill(title: "Advanced Swift", instructor: "Alice", category: "Coding")
        ]
        sut.searchText = ""
        sut.selectedCategory = "All Learners"
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - filteredSkills: No Filter

    func test_filteredSkills_withNoFilterNoSearch_returnsAll() {
        XCTAssertEqual(sut.filteredSkills.count, 4,
                       "With 'All Learners' and empty search, all skills should be returned.")
    }

    // MARK: - filteredSkills: Category Filter

    func test_filteredSkills_withCodingCategory_returnsOnlyCoding() {
        sut.selectedCategory = "Coding"
        XCTAssertEqual(sut.filteredSkills.count, 2)
        XCTAssertTrue(sut.filteredSkills.allSatisfy { $0.category == "Coding" })
    }

    func test_filteredSkills_withDesignCategory_returnsOnlyDesign() {
        sut.selectedCategory = "Design"
        XCTAssertEqual(sut.filteredSkills.count, 1)
        XCTAssertEqual(sut.filteredSkills.first?.title, "Figma Design")
    }

    func test_filteredSkills_withCategoryWithNoMatch_returnsEmpty() {
        sut.selectedCategory = "Music"
        XCTAssertTrue(sut.filteredSkills.isEmpty,
                      "Category with no matching skills should return an empty array.")
    }

    // MARK: - filteredSkills: Search Text

    func test_filteredSkills_searchByTitle_matchesCorrectSkill() {
        sut.searchText = "Figma"
        XCTAssertEqual(sut.filteredSkills.count, 1)
        XCTAssertEqual(sut.filteredSkills.first?.title, "Figma Design")
    }

    func test_filteredSkills_searchByInstructor_returnsMatchingSkills() {
        sut.searchText = "Alice"
        // Alice teaches "Swift Basics" and "Advanced Swift"
        XCTAssertEqual(sut.filteredSkills.count, 2)
        XCTAssertTrue(sut.filteredSkills.allSatisfy { $0.instructor == "Alice" })
    }

    func test_filteredSkills_searchIsCaseInsensitive() {
        sut.searchText = "swift"
        XCTAssertEqual(sut.filteredSkills.count, 2,
                       "Search must be case-insensitive.")
    }

    func test_filteredSkills_searchWithNoMatch_returnsEmpty() {
        sut.searchText = "XYZ_NO_MATCH"
        XCTAssertTrue(sut.filteredSkills.isEmpty)
    }

    // MARK: - filteredSkills: Category + Search Combined

    func test_filteredSkills_categoryAndSearch_narrowsResults() {
        sut.selectedCategory = "Coding"
        sut.searchText = "Advanced"
        XCTAssertEqual(sut.filteredSkills.count, 1)
        XCTAssertEqual(sut.filteredSkills.first?.title, "Advanced Swift")
    }

    func test_filteredSkills_categoryAndSearch_noMatch_returnsEmpty() {
        sut.selectedCategory = "Design"
        sut.searchText = "Swift"
        XCTAssertTrue(sut.filteredSkills.isEmpty,
                      "No Design skill contains 'Swift' — result must be empty.")
    }

    // MARK: - Categories

    func test_categories_containsAllLearners() {
        XCTAssertTrue(sut.categories.contains("All Learners"),
                      "categories must contain 'All Learners' as the default/reset option.")
    }

    func test_categories_countIsCorrect() {
        XCTAssertEqual(sut.categories.count, 6,
                       "categories array must have exactly 6 entries.")
    }

    // MARK: - Navigation Flags

    func test_navigationFlags_defaultToFalse() {
        XCTAssertFalse(sut.navigateToCourses)
        XCTAssertFalse(sut.navigateToSkillMatches)
        XCTAssertFalse(sut.navigateToMap)
    }

    func test_selectedCategory_defaultIsAllLearners() {
        let freshVM = DiscoverViewModel()
        XCTAssertEqual(freshVM.selectedCategory, "All Learners")
    }
}
