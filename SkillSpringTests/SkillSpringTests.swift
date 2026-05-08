// SkillSpringTests.swift
// SkillSpryng — Unit Test Suite
//
// Covers: MockDataProvider integrity, AnalyticsData logic, MapViewModel initialisation.
// Pattern: Arrange → Act → Assert (AAA)
//
// Run: Cmd+U in Xcode, or Product → Test

import XCTest
import MapKit
import FirebaseCore
@testable import SkillSpring

private let _unitTestSummaryObserver: UnitTestSummaryObserver = {
    let observer = UnitTestSummaryObserver.shared
    return observer
}()

// MARK: - MockDataProvider Tests

/// Verifies the integrity of the shared mock data layer.
/// These tests act as a contract — if mock data changes shape,
/// tests break before the UI does.
final class MockDataProviderTests: XCTestCase {

    // MARK: - System Under Test
    private var sut: MockDataProvider!

    override func setUp() {
        super.setUp()
        sut = MockDataProvider.shared
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Profile Tests

    func test_elenaProfile_hasCorrectName() {
        // Arrange: sut initialized in setUp
        // Act
        let name = sut.elenaProfile.fullName
        // Assert
        XCTAssertEqual(name, "Elena Rodriguez",
                       "Elena's profile name must match the stored value.")
    }

    func test_matchProfiles_returnsExpectedCount() {
        XCTAssertEqual(sut.matchProfiles.count, 2,
                       "There should be exactly 2 mock match profiles.")
    }

    func test_recommendedSkills_returnsExpectedCount() {
        XCTAssertEqual(sut.recommendedSkills.count, 3,
                       "There should be exactly 3 recommended skills.")
    }

    func test_matchProfiles_allHavePositiveMatchPercentage() {
        // Every profile must have a positive match % to appear in the feed.
        for profile in sut.matchProfiles {
            XCTAssertGreaterThan(profile.matchPercentage, 0,
                                 "Profile '\(profile.fullName)' must have a positive match percentage.")
        }
    }

    func test_currentUser_hasNonEmptyFullName() {
        XCTAssertFalse(sut.currentUser.fullName.isEmpty,
                       "The current user must always have a name set.")
    }
}

// MARK: - Analytics Data Tests

/// Verifies business rules applied to analytics / gamification data.
final class AnalyticsDataTests: XCTestCase {

    private var analyticsData: AnalyticsData!

    override func setUp() {
        super.setUp()
        analyticsData = MockDataProvider.shared.analyticsData
    }

    func test_streakDays_isSevenDays() {
        XCTAssertEqual(analyticsData.streakDays, 7,
                       "Default streak should be 7 days.")
    }

    func test_growthHistory_containsSevenEntries() {
        XCTAssertEqual(analyticsData.growthHistory.count, 7,
                       "Growth history must contain one entry per day of the week.")
    }

    func test_karmaPoints_exceedsMinimumThreshold() {
        XCTAssertGreaterThan(analyticsData.karmaPoints, 1_000,
                             "Karma points should exceed 1,000 to reflect an active user.")
    }

    func test_growthHistory_allValuesAreNonNegative() {
        for entry in analyticsData.growthHistory {
            XCTAssertGreaterThanOrEqual(entry.value, 0,
                                       "Growth history must not contain negative values.")
        }
    }
}

// MARK: - MapViewModel Tests

/// Verifies the initial state of MapViewModel.
/// Uses `@MainActor` because MapViewModel is an `ObservableObject` with
/// published properties updated on the main thread.
@MainActor
final class MapViewModelTests: XCTestCase {

    private var sut: MapViewModel!

    override func setUp() {
        super.setUp()
        sut = MapViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_initialLocationName_isFindingLocation() {
        XCTAssertEqual(sut.locationName, "Finding location...",
                       "Initial location name should be the loading placeholder.")
    }

    func test_approximateCity_matchesLocationName() {
        XCTAssertEqual(sut.approximateCity, sut.locationName,
                       "approximateCity should alias locationName.")
    }

    func test_calculateMatchPercentage_returnsValidRange() {
        let profile = MockDataProvider.shared.elenaProfile
        let match = sut.calculateMatchPercentage(with: profile)
        XCTAssertTrue(match >= 0 && match <= 100,
                      "Match percentage must be clamped between 0 and 100.")
    }
}

// MARK: - Mock Services

class MockDataSeeder: DataSeedingService {
    var seedAllCalled = false
    func seedAll() async { seedAllCalled = true }
}

class MockDataService: DataService {
    var mockUser: User?
    var walletBalanceUpdate: Int?
    var createdSession: Session?
    var createdTransaction: CreditTransaction?
    var createdMatch: MatchRequest?
    var createdNotification: AppNotification?

    func fetchCurrentUser() async -> User? { mockUser }
    func updateWalletBalance(_ newBalance: Int) async { walletBalanceUpdate = newBalance }
    func createSession(_ session: Session) async throws { createdSession = session }
    func createTransaction(_ transaction: CreditTransaction) async { createdTransaction = transaction }
    func createMatch(_ match: MatchRequest) async throws { createdMatch = match }
    func createNotification(_ notification: AppNotification) async { createdNotification = notification }
    func createConversation(_ conversation: Conversation, currentUserId: String) async { }
}
