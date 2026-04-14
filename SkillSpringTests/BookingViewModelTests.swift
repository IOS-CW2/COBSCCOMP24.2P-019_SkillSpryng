// BookingViewModelTests.swift
// SkillSpryng — BookingViewModel Unit Tests
//
// Tests pricing calculations, date/time parsing helpers, and booking
// flow state transitions inside BookingViewModel.
//
// Pattern: Arrange → Act → Assert (AAA)
// Note: @MainActor required because BookingViewModel publishes UI state.

import XCTest
@testable import SkillSpring

// MARK: - BookingViewModel Tests

@MainActor
final class BookingViewModelTests: XCTestCase {

    // MARK: - System Under Test
    private var sut: BookingViewModel!

    // MARK: - Test Fixtures

    /// A standard mock instructor with a known hourly rate.
    private var mockInstructor: MatchProfile!

    override func setUp() {
        super.setUp()
        mockInstructor = MatchProfile(
            fullName:         "Jane Doe",
            role:             "Designer",
            location:         "Colombo",
            distance:         "2 km",
            matchPercentage:  92,
            bio:              "Test instructor",
            skillsToTeach:    ["Figma", "UX Design"],
            skillsToLearn:    ["Swift"],
            imageUrl:         "elena",
            onlineStatus:     true,
            city:             "Colombo",
            sessionsCount:    20,
            rating:           4.8,
            responseTime:     "< 1 hr",
            availability:     ["Mon", "Wed"],
            reviews:          [],
            hourlyRate:       120   // 120 SKP / hour
        )
        sut = BookingViewModel(instructor: mockInstructor)
    }

    override func tearDown() {
        sut             = nil
        mockInstructor  = nil
        super.tearDown()
    }

    // MARK: - Pricing: sessionPrice

    func test_sessionPrice_for60MinuteDuration_equalsHourlyRate() {
        // Arrange
        sut.selectedDuration = 60
        // Act
        let price = sut.sessionPrice
        // Assert
        XCTAssertEqual(price, 120,
                       "A 60-minute session at 120 SKP/hr should cost exactly 120 SKP.")
    }

    func test_sessionPrice_for30MinuteDuration_equalsHalfHourlyRate() {
        // Arrange
        sut.selectedDuration = 30
        // Act
        let price = sut.sessionPrice
        // Assert
        XCTAssertEqual(price, 60,
                       "A 30-minute session at 120 SKP/hr should cost exactly 60 SKP.")
    }

    func test_sessionPrice_for90MinuteDuration_equals150SKP() {
        // Arrange
        sut.selectedDuration = 90
        // Act
        let price = sut.sessionPrice
        // Assert
        XCTAssertEqual(price, 180,
                       "A 90-minute session at 120 SKP/hr should cost 180 SKP.")
    }

    // MARK: - Pricing: totalPrice (sessionPrice + platformFee)

    func test_totalPrice_includes12SKPPlatformFee() {
        // Arrange
        sut.selectedDuration = 60   // sessionPrice = 120
        // Act
        let total = sut.totalPrice
        // Assert
        XCTAssertEqual(total, 132,
                       "Total price must equal sessionPrice (120) + platform fee (12) = 132.")
    }

    func test_platformFee_isAlways12() {
        XCTAssertEqual(sut.platformFee, 12,
                       "Platform fee must be a fixed 12 SKP regardless of any other state.")
    }

    // MARK: - Date/Time Parsing: buildSessionDate

    func test_buildSessionDate_withAMTime_returnsCorrectHour() {
        // Arrange
        var comps        = DateComponents()
        comps.year       = 2026
        comps.month      = 4
        comps.day        = 20
        let baseDay      = Calendar.current.date(from: comps)!

        // Act
        let result = sut.buildSessionDate(day: baseDay, timeString: "10:00 AM")
        let resultHour = Calendar.current.component(.hour, from: result)

        // Assert
        XCTAssertEqual(resultHour, 10,
                       "Parsing '10:00 AM' should produce hour = 10.")
    }

    func test_buildSessionDate_withPMTime_returnsCorrectHour() {
        // Arrange
        var comps   = DateComponents()
        comps.year  = 2026
        comps.month = 4
        comps.day   = 20
        let baseDay = Calendar.current.date(from: comps)!

        // Act
        let result     = sut.buildSessionDate(day: baseDay, timeString: "2:30 PM")
        let resultHour = Calendar.current.component(.hour, from: result)
        let resultMin  = Calendar.current.component(.minute, from: result)

        // Assert
        XCTAssertEqual(resultHour, 14,
                       "Parsing '2:30 PM' should produce hour = 14 (24h format).")
        XCTAssertEqual(resultMin, 30,
                       "Parsing '2:30 PM' should produce minute = 30.")
    }

    func test_buildSessionDate_withInvalidTimeString_fallsBackTo10AM() {
        // Arrange
        let baseDay = Date()

        // Act
        let result     = sut.buildSessionDate(day: baseDay, timeString: "INVALID")
        let resultHour = Calendar.current.component(.hour, from: result)

        // Assert
        XCTAssertEqual(resultHour, 10,
                       "An unparseable time string should fall back to 10:00 AM.")
    }

    // MARK: - Available Dates

    func test_availableDates_containsSevenDates() {
        XCTAssertEqual(sut.availableDates.count, 7,
                       "availableDates must always return exactly 7 entries (today + next 6 days).")
    }

    func test_availableDates_firstEntryIsToday() {
        // Arrange
        let todayStart = Calendar.current.startOfDay(for: Date())
        // Act
        let firstDate  = sut.availableDates.first!
        // Assert
        XCTAssertEqual(firstDate, todayStart,
                       "The first available date should be the start of today.")
    }

    func test_availableDates_lastEntryIsSixDaysFromNow() {
        let todayStart    = Calendar.current.startOfDay(for: Date())
        let sixDaysAhead  = Calendar.current.date(byAdding: .day, value: 6, to: todayStart)!
        let lastDate      = sut.availableDates.last!

        XCTAssertEqual(lastDate, sixDaysAhead,
                       "The last available date must be 6 days from today.")
    }

    // MARK: - Date Strip Header

    func test_dateStripHeader_isNonEmpty() {
        XCTAssertFalse(sut.dateStripHeader.isEmpty,
                       "dateStripHeader should produce a non-empty string for any date.")
    }

    // MARK: - Booking State — Insufficient Funds

    func test_initiateBooking_withInsufficientFunds_setsShowInsufficientFunds() {
        // Arrange: deplete wallet so balance < totalPrice
        MockDataProvider.shared.currentUser.walletBalance = 0
        sut.selectedDuration = 60   // totalPrice = 132; balance = 0

        // Make instructor "active" so the paid flow triggers
        var activeInstructor  = mockInstructor!
        activeInstructor.status = .active
        let vm = BookingViewModel(instructor: activeInstructor)

        // Act
        vm.initiateBooking()

        // Assert
        XCTAssertTrue(vm.showInsufficientFunds,
                      "initiateBooking with zero balance must flag showInsufficientFunds.")
        XCTAssertFalse(vm.showPaymentSheet,
                       "showPaymentSheet must NOT be shown when funds are insufficient.")
    }

    func test_initiateBooking_withSufficientFunds_setsShowPaymentSheet() {
        // Arrange: set wallet to a comfortable balance
        MockDataProvider.shared.currentUser.walletBalance = 1_000
        sut.selectedDuration = 60   // totalPrice = 132; balance = 1000

        var activeInstructor  = mockInstructor!
        activeInstructor.status = .active
        let vm = BookingViewModel(instructor: activeInstructor)

        // Act
        vm.initiateBooking()

        // Assert
        XCTAssertTrue(vm.showPaymentSheet,
                      "initiateBooking with sufficient funds must open the payment sheet.")
        XCTAssertFalse(vm.showInsufficientFunds,
                       "showInsufficientFunds must NOT be set when balance is sufficient.")
    }

    func test_initiateBooking_withSuggestedInstructor_sendsRequest() {
        // Arrange: instructor in `.suggested` status → free request flow
        var suggestedInstructor  = mockInstructor!
        suggestedInstructor.status = .suggested
        let vm = BookingViewModel(instructor: suggestedInstructor)

        // Act
        vm.initiateBooking()

        // Assert
        XCTAssertTrue(vm.showRequestSent,
                      "A suggested instructor should trigger the request-sent flow, not payment.")
    }
}
