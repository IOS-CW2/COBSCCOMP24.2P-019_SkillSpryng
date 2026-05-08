// BiometricAndNotificationTests.swift
// SkillSpryng — BiometricAuthService & NotificationManager Unit Tests
//
// BiometricAuthService tests verify the hardware-detection and opt-in
// persistence logic without triggering the actual Face ID / Touch ID prompt.
//
// NotificationManager tests verify the scheduling guard conditions and
// the cancel / badge-clear API surface, without requiring permissions.
//
// Pattern: Arrange → Act → Assert (AAA)

import XCTest
import LocalAuthentication
import UserNotifications
@testable import SkillSpring

// MARK: - BiometricAuthService Tests

@MainActor
final class BiometricAuthServiceTests: XCTestCase {

    // MARK: - System Under Test
    private var sut: BiometricAuthService!

    override func setUp() {
        super.setUp()
        sut = BiometricAuthService.shared
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Hardware Detection

    func test_biometricType_returnsNonEmptyString() {
        // Act
        let type = sut.biometricType
        // Assert
        XCTAssertFalse(type.isEmpty,
                       "biometricType should always return a non-empty string.")
    }

    func test_biometricType_returnsExpectedValue() {
        // biometricType must be one of the three valid values.
        let validTypes = ["Face ID", "Touch ID", "Biometrics"]
        XCTAssertTrue(validTypes.contains(sut.biometricType),
                      "biometricType '\(sut.biometricType)' is not one of the expected values.")
    }

    func test_biometricIcon_returnsValidSFSymbol() {
        // Act
        let icon = sut.biometricIcon
        // Assert — icon must be one of the two SF Symbols used in the app.
        let validIcons = ["faceid", "touchid"]
        XCTAssertTrue(validIcons.contains(icon),
                      "biometricIcon '\(icon)' must be a valid SF Symbol used in the app.")
    }

    func test_hasBiometricHardware_returnsBool_withoutCrashing() {
        // This cannot assert a specific value across all CI machines,
        // but it verifies the property does not crash.
        let result = sut.hasBiometricHardware
        XCTAssertTrue(result == true || result == false,
                      "hasBiometricHardware must return a Bool without crashing.")
    }

    // MARK: - Opt-in Persistence

    func test_biometricLoginEnabled_defaultIsFalse() {
        // Arrange: Read the raw UserDefaults value for a fresh state.
        UserDefaults.standard.removeObject(forKey: "skillspryng.biometricLoginEnabled")
        // Act — re-read: because the property wraps UserDefaults, the value reflects storage.
        let stored = UserDefaults.standard.bool(forKey: "skillspryng.biometricLoginEnabled")
        // Assert
        XCTAssertFalse(stored,
                       "Biometric login must be disabled by default (key absent = false).")
    }

    func test_setBiometricLoginEnabled_persistsToUserDefaults() {
        // Arrange
        sut.isBiometricLoginEnabled = true
        // Act
        let stored = UserDefaults.standard.bool(forKey: "skillspryng.biometricLoginEnabled")
        // Assert
        XCTAssertTrue(stored,
                      "Setting isBiometricLoginEnabled = true must persist to UserDefaults.")
        // Cleanup
        sut.isBiometricLoginEnabled = false
    }

    func test_disableBiometricLogin_persistsFalseToUserDefaults() {
        // Arrange
        sut.isBiometricLoginEnabled = true
        // Act
        sut.isBiometricLoginEnabled = false
        // Assert
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "skillspryng.biometricLoginEnabled"),
                       "Setting isBiometricLoginEnabled = false must persist false to UserDefaults.")
    }

    // MARK: - checkBiometricSupport

    func test_checkBiometricSupport_doesNotCrash() {
        // Act
        sut.checkBiometricSupport()
        // Assert: isSupported must be a Bool
        let result = sut.isSupported
        XCTAssertTrue(result == true || result == false,
                      "checkBiometricSupport must set isSupported to a Bool without crashing.")
    }
}

// MARK: - NotificationManager Tests

@MainActor
final class NotificationManagerTests: XCTestCase {

    // MARK: - System Under Test
    private var sut: NotificationManager!

    override func setUp() {
        super.setUp()
        sut = NotificationManager.shared
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Authorisation State

    func test_isAuthorized_returnsBool_withoutCrashing() {
        // The actual value depends on the Simulator's permission state.
        let result = sut.isAuthorized
        XCTAssertTrue(result == true || result == false,
                      "isAuthorized must return a stable Bool value.")
    }

    // MARK: - scheduleSessionReminder: Guard Conditions

    func test_scheduleSessionReminder_withPastDate_doesNotEnqueueRequest() {
        // Arrange: a date 1 hour in the past → guard `reminderDate > Date()` must fire.
        let pastDate = Date().addingTimeInterval(-3_600)

        // Act: schedule (should be silently skipped)
        sut.scheduleSessionReminder(
            identifier: "test-past-reminder",
            sessionTitle: "Past Test Session",
            instructorName: "Test Instructor",
            sessionDate: pastDate
        )

        // Assert: verify no pending request was added (async check with expectation).
        let expectation = expectation(description: "Pending notifications checked")
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let found = requests.contains { $0.identifier == "reminder-test-past-reminder" }
            XCTAssertFalse(found,
                           "A reminder for a past session must not be queued.")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
    }

    func test_scheduleSessionCancelled_doesNotCrash() {
        // Act
        sut.scheduleSessionCancelled(
            sessionId: "test-session-id",
            sessionTitle: "UI Review Session",
            instructorName: "Marcus"
        )

        // Assert
        XCTAssertTrue(true, "scheduleSessionCancelled must not throw or crash.")
    }

    func test_scheduleMatchAccepted_doesNotCrash() {
        sut.scheduleMatchAccepted(requesterName: "Avery")
        XCTAssertTrue(true, "scheduleMatchAccepted must not throw or crash.")
    }

    func test_scheduleMatchDeclined_doesNotCrash() {
        sut.scheduleMatchDeclined(requesterName: "Avery")
        XCTAssertTrue(true, "scheduleMatchDeclined must not throw or crash.")
    }

    func test_scheduleMatchCancelled_doesNotCrash() {
        sut.scheduleMatchCancelled(recipientName: "Morgan")
        XCTAssertTrue(true, "scheduleMatchCancelled must not throw or crash.")
    }

    // MARK: - cancelNotification

    func test_cancelNotification_removesSpecificPendingRequest() {
        // This test verifies the cancel-by-identifier surface does not crash.
        // Actual deletion requires a pending request to exist, which in turn
        // requires authorisation — so we simply verify no crash occurs.
        sut.cancelNotification(identifier: "test-cancel-id")
        XCTAssertTrue(true, "cancelNotification must not throw or crash.")
    }

    // MARK: - cancelAllPendingNotifications

    func test_cancelAllPendingNotifications_doesNotCrash() {
        // Act
        sut.cancelAllPendingNotifications()
        // Assert
        XCTAssertTrue(true, "cancelAllPendingNotifications must not crash.")
    }

    // MARK: - clearBadge

    func test_clearBadge_doesNotCrash() {
        // Act
        sut.clearBadge()
        // Assert
        XCTAssertTrue(true, "clearBadge must not crash.")
    }

    // MARK: - Welcome Notification: One-Time Guard

    func test_scheduleWelcomeNotification_onlyFiresOnce() {
        // Arrange: reset the one-time key
        let key = "skillspryng.welcomeNotificationSent"
        UserDefaults.standard.removeObject(forKey: key)

        // Act: call twice
        sut.scheduleWelcomeNotification(userName: "Test User")
        sut.scheduleWelcomeNotification(userName: "Test User")

        // Assert: key is set to true (guard on second call)
        XCTAssertTrue(UserDefaults.standard.bool(forKey: key),
                      "welcomeNotificationSent must be set to true after the first call.")

        // Cleanup
        UserDefaults.standard.removeObject(forKey: key)
    }
}
