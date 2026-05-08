// CalendarServiceTests.swift
// SkillSpryng — CalendarService Unit Tests
//
// Tests the core booking-conflict detection and time-slot availability logic
// inside CalendarService. These are pure-logic tests — no EKEventStore calls
// are made, so they run without Calendar permissions.
//
// Pattern: Arrange → Act → Assert (AAA)

import XCTest
@testable import SkillSpring

// MARK: - CalendarService — isTimeSlotAvailable

final class CalendarServiceTests: XCTestCase {

    // MARK: - System Under Test
    private var sut: CalendarService!

    // MARK: - Test Fixtures
    /// A fixed reference date: 14 April 2026, 10:00 AM
    private var referenceDate: Date!

    override func setUp() {
        super.setUp()
        sut = CalendarService.shared

        // Build a deterministic date so tests are not time-dependent.
        var components        = DateComponents()
        components.year       = 2026
        components.month      = 4
        components.day        = 14
        components.hour       = 10
        components.minute     = 0
        components.second     = 0
        referenceDate = Calendar.current.date(from: components)!
    }

    override func tearDown() {
        sut         = nil
        referenceDate = nil
        super.tearDown()
    }

    // MARK: - Helpers

    /// Creates a DateInterval starting at `referenceDate + offsetHours`
    /// and lasting `durationHours`.
    private func makeInterval(offsetHours: Double, durationHours: Double) -> DateInterval {
        let start = referenceDate.addingTimeInterval(offsetHours * 3_600)
        let end   = start.addingTimeInterval(durationHours * 3_600)
        return DateInterval(start: start, end: end)
    }

    // MARK: - Happy Path: No Conflicts

    func test_isTimeSlotAvailable_withEmptyBusySlots_returnsTrue() {
        // Arrange
        let busySlots: [DateInterval] = []
        let startTime: Date = referenceDate   // 10:00 AM
        let duration  = 60              // 60 min

        // Act
        let available = sut.isTimeSlotAvailable(startTime: startTime,
                                                 durationMinutes: duration,
                                                 busySlots: busySlots)
        // Assert
        XCTAssertTrue(available,
                      "An empty calendar should always return available.")
    }

    func test_isTimeSlotAvailable_withNonOverlappingSlot_returnsTrue() {
        // Arrange: busy from 08:00–09:00; proposed 10:00–11:00
        let busySlots = [makeInterval(offsetHours: -2, durationHours: 1)]
        let startTime: Date = referenceDate   // 10:00 AM
        let duration  = 60

        // Act
        let available = sut.isTimeSlotAvailable(startTime: startTime,
                                                 durationMinutes: duration,
                                                 busySlots: busySlots)
        // Assert
        XCTAssertTrue(available,
                      "A slot that does not overlap an existing event should be available.")
    }

    // MARK: - Conflict Detection

    func test_isTimeSlotAvailable_withDirectOverlap_returnsFalse() {
        // Arrange: busy from 10:00–11:00; proposed 10:00–11:00 (identical)
        let busySlots = [makeInterval(offsetHours: 0, durationHours: 1)]
        let startTime: Date = referenceDate
        let duration  = 60

        // Act
        let available = sut.isTimeSlotAvailable(startTime: startTime,
                                                 durationMinutes: duration,
                                                 busySlots: busySlots)
        // Assert
        XCTAssertFalse(available,
                       "A slot that exactly overlaps an existing event must be unavailable.")
    }

    func test_isTimeSlotAvailable_withPartialOverlapAtStart_returnsFalse() {
        // Arrange: busy from 09:30–10:30; proposed 10:00–11:00
        let busySlots = [makeInterval(offsetHours: -0.5, durationHours: 1)]
        let startTime: Date = referenceDate   // 10:00
        let duration  = 60

        // Act
        let available = sut.isTimeSlotAvailable(startTime: startTime,
                                                 durationMinutes: duration,
                                                 busySlots: busySlots)
        // Assert
        XCTAssertFalse(available,
                       "A slot that partially overlaps at the start of a busy event must be unavailable.")
    }

    func test_isTimeSlotAvailable_withPartialOverlapAtEnd_returnsFalse() {
        // Arrange: busy from 10:30–11:30; proposed 10:00–11:00
        let busySlots = [makeInterval(offsetHours: 0.5, durationHours: 1)]
        let startTime: Date = referenceDate   // 10:00
        let duration  = 60

        // Act
        let available = sut.isTimeSlotAvailable(startTime: startTime,
                                                 durationMinutes: duration,
                                                 busySlots: busySlots)
        // Assert
        XCTAssertFalse(available,
                       "A slot that overlaps at the tail of a busy event must be unavailable.")
    }

    func test_isTimeSlotAvailable_withProposedSlotInsideLargerBusyBlock_returnsFalse() {
        // Arrange: busy from 09:00–13:00 (4-hour block); proposed 10:00–11:00
        let busySlots = [makeInterval(offsetHours: -1, durationHours: 4)]
        let startTime: Date = referenceDate
        let duration  = 60

        // Act
        let available = sut.isTimeSlotAvailable(startTime: startTime,
                                                 durationMinutes: duration,
                                                 busySlots: busySlots)
        // Assert
        XCTAssertFalse(available,
                       "A proposed slot entirely inside a longer busy block must be unavailable.")
    }

    // MARK: - Edge Cases

    func test_isTimeSlotAvailable_withZeroDuration_doesNotCrash() {
        // Arrange
        let busySlots: [DateInterval] = []
        let startTime: Date = referenceDate

        // Act — should not crash, result is implementation-defined
        let _ = sut.isTimeSlotAvailable(startTime: startTime,
                                         durationMinutes: 0,
                                         busySlots: busySlots)
        // Assert (no crash = pass)
        XCTAssertTrue(true, "Zero-duration slot must not cause a crash.")
    }

    func test_isTimeSlotAvailable_withMultipleBusySlots_detectsConflictInAny() {
        // Arrange: two non-overlapping busy events; proposed slot overlaps only the second
        let busySlots = [
            makeInterval(offsetHours: -3, durationHours: 1),  // 07:00–08:00
            makeInterval(offsetHours: 0,  durationHours: 1)   // 10:00–11:00 ← conflict
        ]
        let startTime: Date = referenceDate   // 10:00
        let duration  = 60

        // Act
        let available = sut.isTimeSlotAvailable(startTime: startTime,
                                                 durationMinutes: duration,
                                                 busySlots: busySlots)
        // Assert
        XCTAssertFalse(available,
                       "A conflict with ANY busy slot must make the proposed slot unavailable.")
    }

    // MARK: - checkCalendarAccess

    func test_checkCalendarAccess_returnsBoolean_withoutCrashing() {
        // Act
        let result = sut.checkCalendarAccess()
        // Assert: value doesn't matter on Simulator (depends on permission state),
        // but the call must not crash.
        XCTAssertTrue(result == true || result == false,
                      "checkCalendarAccess must return a Bool without crashing.")
    }
}
