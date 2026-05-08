// BookingViewModelTests.swift
// SkillSpryng — BookingViewModel Unit Tests

import XCTest
import Combine
@testable import SkillSpring

// MARK: - BookingViewModel Tests

@MainActor
final class BookingViewModelTests: XCTestCase {

    // MARK: - System Under Test
    private var sut: BookingViewModel!
    private var mockDS: MockDataService!

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
        mockDS = MockDataService()
        // Provide a default user with 0 balance
        mockDS.mockUser = User(id: "TEST_UID", fullName: "Tester", walletBalance: 0)
        sut = BookingViewModel(instructor: mockInstructor, dataService: mockDS)
    }

    override func tearDown() {
        sut             = nil
        mockInstructor  = nil
        mockDS          = nil
        super.tearDown()
    }

    // MARK: - Pricing: sessionPrice

    func test_sessionPrice_for60MinuteDuration_equalsHourlyRate() {
        // Arrange
        sut.selectedDuration = 60
        // Act
        let price = sut.sessionPrice
        // Assert
        XCTAssertEqual(price, 120)
    }

    func test_sessionPrice_for30MinuteDuration_equalsHalfHourlyRate() {
        // Arrange
        sut.selectedDuration = 30
        // Act
        let price = sut.sessionPrice
        // Assert
        XCTAssertEqual(price, 60)
    }

    func test_sessionPrice_for90MinuteDuration_equals180SKP() {
        // Arrange
        sut.selectedDuration = 90
        // Act
        let price = sut.sessionPrice
        // Assert
        XCTAssertEqual(price, 180)
    }

    // MARK: - Pricing: totalPrice (sessionPrice + platformFee)

    func test_totalPrice_includes12SKPPlatformFee() {
        // Arrange
        sut.selectedDuration = 60   // sessionPrice = 120
        // Act
        let total = sut.totalPrice
        // Assert
        XCTAssertEqual(total, 132)
    }

    func test_platformFee_isAlways12() {
        XCTAssertEqual(sut.platformFee, 12)
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
        XCTAssertEqual(resultHour, 10)
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
        XCTAssertEqual(resultHour, 14)
        XCTAssertEqual(resultMin, 30)
    }

    // MARK: - Available Dates

    func test_availableDates_containsSevenDates() {
        XCTAssertEqual(sut.availableDates.count, 7)
    }

    // MARK: - Booking State — Insufficient Funds

    func test_initiateBooking_withInsufficientFunds_setsShowInsufficientFunds() async {
        // Arrange: wallet balance is 0 by default in mockDS
        sut.selectedDuration = 60   // totalPrice = 132; balance = 0

        var activeInstructor  = mockInstructor!
        activeInstructor.status = .active
        
        let mockEmptyDS = MockDataService()
        mockEmptyDS.mockUser = User(id: "0_UID", fullName: "No Money", walletBalance: 0)
        
        let vm = BookingViewModel(instructor: activeInstructor, dataService: mockEmptyDS)
        
        // Wait for loadBalance
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Act
        vm.initiateBooking()

        // Assert
        XCTAssertTrue(vm.showInsufficientFunds)
        XCTAssertFalse(vm.showPaymentSheet)
    }

    func test_initiateBooking_withSufficientFunds_setsShowPaymentSheet() async {
        // Arrange: set wallet to a comfortable balance
        let mockRichDS = MockDataService()
        mockRichDS.mockUser = User(id: "RICH_UID", fullName: "Wealthy User", walletBalance: 1000)
        
        var activeInstructor  = mockInstructor!
        activeInstructor.status = .active
        
        let vm = BookingViewModel(instructor: activeInstructor, dataService: mockRichDS)

        // Wait for loadBalance using expectation
        let exp = expectation(description: "Balance loaded")
        let cancellable = vm.$userBalance
            .filter { $0 == 1000 }
            .first()
            .sink { _ in exp.fulfill() }
        
        await fulfillment(of: [exp], timeout: 2.0)
        cancellable.cancel()

        // Act
        vm.initiateBooking()

        // Assert
        XCTAssertTrue(vm.showPaymentSheet)
        XCTAssertFalse(vm.showInsufficientFunds)
    }

    func test_initiateBooking_withSuggestedInstructor_sendsRequest() async {
        // Arrange: instructor in `.suggested` status → free request flow
        var suggestedInstructor  = mockInstructor!
        suggestedInstructor.status = .suggested
        
        let mockDS = MockDataService()
        mockDS.mockUser = User(id: "UID", fullName: "User", walletBalance: 0)
        
        let vm = BookingViewModel(instructor: suggestedInstructor, dataService: mockDS)
        
        // Wait for leadBalance
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Act
        vm.initiateBooking()
        
        // confirmBooking is async, wait for it
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Assert
        XCTAssertTrue(vm.showRequestSent)
    }
}
