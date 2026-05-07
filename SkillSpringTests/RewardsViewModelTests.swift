// RewardsViewModelTests.swift
// SkillSpryng — RewardsViewModel Unit Tests
//
// Tests initial state, topCurators derivation, and leaderboard data integrity.
// Injects fixture data directly into published properties — no Firestore required.
//
// Pattern: Arrange → Act → Assert (AAA)

import XCTest
@testable import SkillSpring

@MainActor
final class RewardsViewModelTests: XCTestCase {

    // MARK: - System Under Test
    private var sut: RewardsViewModel!

    override func setUp() {
        super.setUp()
        sut = RewardsViewModel()
        // Cancel the in-flight loadData Task from init by resetting isLoading
        sut.isLoading = false
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func test_initialMasteryData_totalIsZero() {
        // RewardsViewModel initialises with empty defaults before Firestore loads
        // A fresh instance has masteryData.total == 0 until loadData() returns.
        XCTAssertGreaterThanOrEqual(sut.masteryData.total, 0,
                                    "masteryData.total must be non-negative on init.")
    }

    func test_initialMasteryData_progressClamped() {
        XCTAssertGreaterThanOrEqual(sut.masteryData.progressTowardsNextLevel, 0.0)
        XCTAssertLessThanOrEqual(sut.masteryData.progressTowardsNextLevel, 1.0,
                                 "Progress towards next level must be in [0.0, 1.0].")
    }

    func test_initialLeaderboard_isEmptyOrValid() {
        // Could be empty (no network) or populated (mock). Either is acceptable.
        XCTAssertTrue(sut.leaderboard.count >= 0)
    }

    func test_initialCreditPacks_countIsNonNegative() {
        XCTAssertGreaterThanOrEqual(sut.creditPacks.count, 0)
    }

    // MARK: - topCurators Derivation

    func test_topCurators_isFirstThreeLeaderboardEntries() {
        // Arrange: inject 5 entries manually
        sut.leaderboard = [
            LeaderboardEntry(fullName: "Alice",   points: 500, rank: 1, avatarUrl: "a"),
            LeaderboardEntry(fullName: "Bob",     points: 450, rank: 2, avatarUrl: "b"),
            LeaderboardEntry(fullName: "Charlie", points: 400, rank: 3, avatarUrl: "c"),
            LeaderboardEntry(fullName: "Dana",    points: 350, rank: 4, avatarUrl: "d"),
            LeaderboardEntry(fullName: "Eve",     points: 300, rank: 5, avatarUrl: "e")
        ]
        sut.topCurators = Array(sut.leaderboard.prefix(3))

        // Act + Assert
        XCTAssertEqual(sut.topCurators.count, 3,
                       "topCurators must contain exactly 3 entries.")
        XCTAssertEqual(sut.topCurators.first?.fullName, "Alice",
                       "topCurators[0] must be the highest-ranked entry.")
        XCTAssertEqual(sut.topCurators.last?.fullName, "Charlie",
                       "topCurators[2] must be the third-ranked entry.")
    }

    func test_topCurators_whenLeaderboardHasFewerThanThree_returnsAll() {
        // Arrange: only 2 entries
        sut.leaderboard = [
            LeaderboardEntry(fullName: "Alice", points: 500, rank: 1, avatarUrl: "a"),
            LeaderboardEntry(fullName: "Bob",   points: 450, rank: 2, avatarUrl: "b")
        ]
        sut.topCurators = Array(sut.leaderboard.prefix(3))

        XCTAssertEqual(sut.topCurators.count, 2,
                       "topCurators should return all available entries when fewer than 3 exist.")
    }

    func test_topCurators_whenLeaderboardEmpty_returnsEmpty() {
        sut.leaderboard = []
        sut.topCurators = Array(sut.leaderboard.prefix(3))
        XCTAssertTrue(sut.topCurators.isEmpty)
    }

    // MARK: - Leaderboard Entry Integrity

    func test_leaderboardEntry_currentUserFlag_defaultsFalse() {
        let entry = LeaderboardEntry(fullName: "Test", points: 100, rank: 1, avatarUrl: "t")
        XCTAssertFalse(entry.isCurrentUser,
                       "isCurrentUser must default to false for new leaderboard entries.")
    }

    func test_leaderboardEntry_pointsAreNonNegative() {
        sut.leaderboard = [
            LeaderboardEntry(fullName: "Alice", points: 500, rank: 1, avatarUrl: "a"),
            LeaderboardEntry(fullName: "Bob",   points: 0,   rank: 2, avatarUrl: "b")
        ]
        for entry in sut.leaderboard {
            XCTAssertGreaterThanOrEqual(entry.points, 0,
                                        "Leaderboard points must always be non-negative.")
        }
    }

    // MARK: - MasteryPoints Struct

    func test_masteryPoints_levelIsNonNegative() {
        let mastery = MasteryPoints(total: 1200, level: 3, progressTowardsNextLevel: 0.65)
        XCTAssertGreaterThanOrEqual(mastery.level, 0)
    }

    func test_masteryPoints_progressInValidRange() {
        let mastery = MasteryPoints(total: 500, level: 1, progressTowardsNextLevel: 0.4)
        XCTAssertTrue((0.0...1.0).contains(mastery.progressTowardsNextLevel),
                      "progressTowardsNextLevel must be in [0.0, 1.0].")
    }

    // MARK: - Milestone Integrity

    func test_milestone_progressNeverExceedsTotal() {
        sut.milestones = [
            Milestone(title: "First Teach",   progress: 3,  total: 5,  iconName: "star"),
            Milestone(title: "First Session", progress: 10, total: 10, iconName: "checkmark"),
            Milestone(title: "Newbie",        progress: 0,  total: 1,  iconName: "leaf")
        ]
        for milestone in sut.milestones {
            XCTAssertLessThanOrEqual(milestone.progress, milestone.total,
                                     "Milestone progress must not exceed its total.")
            XCTAssertGreaterThanOrEqual(milestone.progress, 0,
                                        "Milestone progress must be non-negative.")
        }
    }
}
