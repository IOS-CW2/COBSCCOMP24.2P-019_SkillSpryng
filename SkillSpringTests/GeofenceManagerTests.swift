// GeofenceManagerTests.swift
// SkillSpryng Unit Tests
//
// Tests the GeofenceManager state machine using the #if DEBUG simulate helpers.
// No live location hardware is required — the simulate methods drive the same
// internal handlers that CLLocationManagerDelegate calls on a real device.
//
// Run: Cmd+U   ·   Pattern: Arrange → Act → Assert (AAA)

import XCTest
@testable import SkillSpring

@MainActor
final class GeofenceManagerTests: XCTestCase {

    private var sut: GeofenceManager!

    override func setUp() async throws {
        try await super.setUp()
        sut = GeofenceManager.shared
        // Simulate a session being active so the handlers have a region to match
        // We set the private properties via the public start API using a fake coordinate.
        // (CLLocationManager won't register the region on Simulator, but activeRegionId is set.)
        sut.startMonitoring(
            sessionTitle: "Test Session",
            coordinate: .init(latitude: 6.9271, longitude: 79.8612)
        )
    }

    override func tearDown() async throws {
        sut.stopMonitoring()
        try await super.tearDown()
    }

    // MARK: - Initial State

    func test_initialState_isMonitoring() {
        XCTAssertTrue(sut.isMonitoring,
                      "isMonitoring should be true after startMonitoring is called.")
    }

    func test_initialState_userNotLeftSession() {
        XCTAssertFalse(sut.userLeftSession,
                       "userLeftSession should be false on session start.")
    }

    // MARK: - Exit Flow

    func test_simulateExit_setsUserLeftSession() {
        // Act
        sut.simulateGeofenceExit()
        // Assert
        XCTAssertTrue(sut.userLeftSession,
                      "userLeftSession must be true after a geofence exit event.")
    }

    func test_simulateExit_clearsReturnedFlag() {
        // Arrange — first simulate a return so the flag is true
        sut.simulateGeofenceExit()
        sut.simulateGeofenceReturn()
        // Sanity: return flag should be set
        XCTAssertTrue(sut.userReturnedToArea)

        // Act — exit again
        sut.simulateGeofenceExit()

        // Assert — return flag should be cleared on exit
        XCTAssertFalse(sut.userReturnedToArea,
                       "userReturnedToArea must be cleared when a new exit event fires.")
    }

    // MARK: - Return Flow

    func test_simulateReturn_afterExit_clearsUserLeftSession() {
        // Arrange
        sut.simulateGeofenceExit()
        XCTAssertTrue(sut.userLeftSession)

        // Act
        sut.simulateGeofenceReturn()

        // Assert
        XCTAssertFalse(sut.userLeftSession,
                       "userLeftSession should be cleared when the user returns.")
        XCTAssertTrue(sut.userReturnedToArea,
                      "userReturnedToArea should be set when the user returns.")
    }

    func test_simulateReturn_withoutPriorExit_hasNoEffect() {
        // Act — return without having exited
        sut.simulateGeofenceReturn()

        // Assert — no state change because userLeftSession was still false
        XCTAssertFalse(sut.userLeftSession)
        XCTAssertFalse(sut.userReturnedToArea,
                       "Spurious return event should not flip userReturnedToArea.")
    }

    // MARK: - Safe Confirmation

    func test_handleUserConfirmedSafe_clearsExitFlag() {
        // Arrange
        sut.simulateGeofenceExit()
        XCTAssertTrue(sut.userLeftSession)

        // Act
        sut.handleUserConfirmedSafe()

        // Assert
        XCTAssertFalse(sut.userLeftSession,
                       "Confirming safe should clear userLeftSession.")
    }

    // MARK: - Stop Monitoring

    func test_stopMonitoring_clearsAllState() {
        // Arrange
        sut.simulateGeofenceExit()

        // Act
        sut.stopMonitoring()

        // Assert
        XCTAssertFalse(sut.isMonitoring,    "isMonitoring must be false after stop.")
        XCTAssertFalse(sut.userLeftSession, "userLeftSession must be cleared after stop.")
    }
}
