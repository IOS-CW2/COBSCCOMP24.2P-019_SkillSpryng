// SessionsViewModelTests.swift
// SkillSpryng — SessionsViewModel Unit Tests
//
// Tests all derived computed properties (upcomingSessions, completedSessions,
// cancelledSessions, historySessions, todaySession, tomorrowSession) by
// injecting fixture sessions directly into `sessions` — no live Firestore required.
//
// Pattern: Arrange → Act → Assert (AAA)

import XCTest
@testable import SkillSpring

@MainActor
final class SessionsViewModelTests: XCTestCase {

    // MARK: - System Under Test
    private var sut: SessionsViewModel!

    // MARK: - Fixtures

    private func makeSession(
        title: String = "Test Session",
        status: SessionStatus,
        type: SessionType = .online
    ) -> Session {
        Session(
            title: title,
            instructorName: "Test Instructor",
            instructorRole: "Instructor",
            date: "May 6, 2026",
            time: "10:00 AM",
            duration: "60 min",
            location: nil,
            distance: nil,
            timeRemaining: "1h",
            status: status,
            type: type,
            category: "Development",
            rating: nil,
            notes: nil,
            matchPercentage: 80,
            scheduledAt: Date()
        )
    }

    override func setUp() {
        super.setUp()
        sut = SessionsViewModel()
        // Inject known fixtures — bypasses Firestore listener
        sut.sessions = []
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - upcomingSessions

    func test_upcomingSessions_returnsOnlyUpcoming() {
        // Arrange
        sut.sessions = [
            makeSession(status: .upcoming),
            makeSession(status: .completed),
            makeSession(status: .cancelled)
        ]
        // Act + Assert
        XCTAssertEqual(sut.upcomingSessions.count, 1)
        XCTAssertEqual(sut.upcomingSessions.first?.status, .upcoming)
    }

    func test_upcomingSessions_whenNone_returnsEmpty() {
        sut.sessions = [makeSession(status: .completed), makeSession(status: .cancelled)]
        XCTAssertTrue(sut.upcomingSessions.isEmpty)
    }

    // MARK: - completedSessions

    func test_completedSessions_returnsOnlyCompleted() {
        sut.sessions = [
            makeSession(status: .upcoming),
            makeSession(status: .completed),
            makeSession(status: .completed)
        ]
        XCTAssertEqual(sut.completedSessions.count, 2)
        XCTAssertTrue(sut.completedSessions.allSatisfy { $0.status == .completed })
    }

    // MARK: - cancelledSessions

    func test_cancelledSessions_returnsOnlyCancelled() {
        sut.sessions = [
            makeSession(status: .upcoming),
            makeSession(status: .cancelled)
        ]
        XCTAssertEqual(sut.cancelledSessions.count, 1)
        XCTAssertEqual(sut.cancelledSessions.first?.status, .cancelled)
    }

    // MARK: - historySessions

    func test_historySessions_includesCompletedAndCancelled() {
        // Arrange
        sut.sessions = [
            makeSession(status: .upcoming),
            makeSession(status: .completed),
            makeSession(status: .cancelled),
            makeSession(status: .completed)
        ]
        // Act + Assert
        XCTAssertEqual(sut.historySessions.count, 3,
                       "historySessions should include completed and cancelled — not upcoming.")
    }

    func test_historySessions_excludesUpcoming() {
        sut.sessions = [makeSession(status: .upcoming)]
        XCTAssertTrue(sut.historySessions.isEmpty)
    }

    // MARK: - todaySession

    func test_todaySession_returnsFirstOnlineUpcoming() {
        // Arrange
        let onlineSession    = makeSession(title: "Online Session", status: .upcoming, type: .online)
        let inPersonSession  = makeSession(title: "In-Person Session", status: .upcoming, type: .inPerson)
        sut.sessions = [inPersonSession, onlineSession]
        // Act + Assert
        XCTAssertEqual(sut.todaySession?.title, "Online Session",
                       "todaySession must be the first upcoming online session.")
    }

    func test_todaySession_isNilWhenNoOnlineSession() {
        sut.sessions = [makeSession(status: .upcoming, type: .inPerson)]
        XCTAssertNil(sut.todaySession)
    }

    func test_todaySession_isNilWhenNoUpcomingSessions() {
        sut.sessions = [makeSession(status: .completed, type: .online)]
        XCTAssertNil(sut.todaySession)
    }

    // MARK: - tomorrowSession

    func test_tomorrowSession_returnsSecondUpcoming() {
        // Arrange
        let first  = makeSession(title: "First", status: .upcoming)
        let second = makeSession(title: "Second", status: .upcoming)
        let third  = makeSession(title: "Third", status: .upcoming)
        sut.sessions = [first, second, third]
        // Act + Assert
        XCTAssertEqual(sut.tomorrowSession?.title, "Second",
                       "tomorrowSession should be the second element of upcomingSessions.")
    }

    func test_tomorrowSession_isNilWhenOnlyOneUpcoming() {
        sut.sessions = [makeSession(status: .upcoming)]
        XCTAssertNil(sut.tomorrowSession)
    }

    // MARK: - sessions array integrity

    func test_sessions_initiallyEmpty_afterManualReset() {
        XCTAssertTrue(sut.sessions.isEmpty,
                      "sessions should be empty after setUp injected an empty array.")
    }

    func test_allFilters_sumToTotalSessions() {
        // Arrange
        sut.sessions = [
            makeSession(status: .upcoming),
            makeSession(status: .upcoming),
            makeSession(status: .completed),
            makeSession(status: .cancelled)
        ]
        let total = sut.upcomingSessions.count
                  + sut.completedSessions.count
                  + sut.cancelledSessions.count
        // Act + Assert
        XCTAssertEqual(total, sut.sessions.count,
                       "Upcoming + Completed + Cancelled must equal total sessions count.")
    }
}
