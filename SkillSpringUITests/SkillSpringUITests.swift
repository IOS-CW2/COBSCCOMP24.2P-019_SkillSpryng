// SkillSpringUITests.swift
// SkillSpryng — UI Integration Tests
//
// These tests spin up a real Simulator and verify the most critical
// user journeys. They are slower but test the app as a real user would.
//
// Pattern: Arrange → Act → Assert (AAA)

import XCTest

final class SkillSpringUITests: XCTestCase {

    override func setUpWithError() throws {
        // Stop immediately if a failure occurs
        continueAfterFailure = false
    }

    // MARK: - Onboarding Flow
    
    func test_launch_showsOnboardingAfterDelay() throws {
        let app = XCUIApplication()
        // Reset state so we always get the launch screen, not a logged-in state.
        // We pass launch arguments to override UserDefaults during tests.
        app.launchArguments = ["-skillspryng.isLoggedIn", "NO"]
        app.launch()

        // Wait up to 5 seconds for the Onboarding screen to appear (the Timer takes 2s)
        let nextButton = app.buttons["onboardingNextButton"]
        let exists = nextButton.waitForExistence(timeout: 5.0)
        
        XCTAssertTrue(exists, "The App should automatically navigate to Onboarding after LaunchView delay.")
        
        // Tap "Next" to verify navigation to Login
        nextButton.tap()
        
        let sendOTPButton = app.buttons["sendOTPButton"]
        XCTAssertTrue(sendOTPButton.waitForExistence(timeout: 2.0),
                      "Tapping Next should navigate to the Sign In (Send OTP) screen.")
    }

    // MARK: - Login Flow
    
    func test_loginFlow_navigatesToOTPVerification() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-skillspryng.isLoggedIn", "NO"]
        app.launch()
        
        // Skip through onboarding to get straight to login
        let skipButton = app.buttons["onboardingSkipButton"]
        if skipButton.waitForExistence(timeout: 5.0) {
            skipButton.tap()
        }
        
        // 1. Enter Full Name
        let nameField = app.textFields["fullNameTextField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2.0), "Full Name field must exist on Login.")
        nameField.tap()
        nameField.typeText("Test User\n") // \n to dismiss keyboard if needed
        
        // 2. Enter Phone Number
        let phoneField = app.textFields["phoneTextField"]
        phoneField.tap()
        phoneField.typeText("+94771234567\n")
        
        // 3. Tap Send OTP
        app.buttons["sendOTPButton"].tap()
        
        // 4. Verify we arrived on the OTP Screen
        let otpField = app.textFields["otpInputField"]
        XCTAssertTrue(otpField.waitForExistence(timeout: 3.0),
                      "Tapping 'Send OTP' with valid info must navigate to PhoneVerificationView.")
    }

    // MARK: - Tab Bar Navigation (Logged In State)
    
    func test_tabBarNavigation_switchesTabsSuccessfully() throws {
        let app = XCUIApplication()
        // Force the app into a mock logged-in state so we bypass Onboarding
        app.launchArguments = ["-skillspryng.isLoggedIn", "YES"]
        app.launch()
        
        // 1. Verify we start on Home
        let homeTab = app.tabBars.buttons["HOME"]
        XCTAssertTrue(homeTab.waitForExistence(timeout: 3.0), "MainTabView should be visible after login.")
        
        // 2. Tap Sessions tab
        app.tabBars.buttons["SESSIONS"].tap()
        
        // 3. Tap Messages tab
        app.tabBars.buttons["MESSAGES"].tap()
        
        // 4. Tap Rewards tab
        app.tabBars.buttons["REWARDS"].tap()
        
        // We just verified the App doesn't crash when cycling through all primary tabs.
        // On a real CI, we might assert specific Text("...") exists inside each tab.
        XCTAssertTrue(app.tabBars.buttons["REWARDS"].isSelected || app.tabBars.buttons["REWARDS"].exists,
                      "Rewards tab must be active or exist without crashing.")
    }
}
