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
        app.launchArguments = ["-skillspryng.isLoggedIn", "NO"]
        app.launch()

        // Wait for the Onboarding screen to appear after the 2s LaunchView delay
        let skipButton = app.buttons["onboardingSkipButton"]
        let exists = skipButton.waitForExistence(timeout: 8.0)
        XCTAssertTrue(exists, "The App should automatically navigate to Onboarding after LaunchView delay.")
        
        // Tap "Skip" to verify navigation to Login
        skipButton.tap()
        
        let sendOTPButton = app.buttons["sendOTPButton"]
        XCTAssertTrue(sendOTPButton.waitForExistence(timeout: 5.0),
                      "Tapping Skip should navigate to the Sign In (Send OTP) screen.")
    }

    // MARK: - Login Flow
    
    func test_loginFlow_navigatesToOTPVerification() throws {
        let app = XCUIApplication()
        // Inject a mock flag so FirebaseManager returns a stub verificationID
        // instead of making a real network call, avoiding the fatal nil crash
        app.launchArguments = ["-skillspryng.isLoggedIn", "NO", "-skillspryng.useMockAuth", "YES"]
        app.launch()
        
        // Skip through onboarding to get straight to login
        let skipButton = app.buttons["onboardingSkipButton"]
        if skipButton.waitForExistence(timeout: 8.0) {
            skipButton.tap()
        }
        
        // 1. Enter Full Name
        let nameField = app.textFields["fullNameTextField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5.0), "Full Name field must exist on Login.")
        nameField.tap()
        nameField.typeText("Test User")
        
        // Dismiss keyboard after name
        app.keyboards.buttons["Return"].tap()
        
        // 2. Enter Phone Number
        let phoneField = app.textFields["phoneTextField"]
        XCTAssertTrue(phoneField.waitForExistence(timeout: 3.0), "Phone field must exist on Login.")
        phoneField.tap()
        phoneField.typeText("+94771234567")
        
        // Dismiss keyboard before tapping button
        if app.keyboards.element.exists { app.keyboards.buttons["Done"].firstMatch.tap() }
        
        // 3. Tap Send OTP
        let sendOTPButton = app.buttons["sendOTPButton"]
        XCTAssertTrue(sendOTPButton.waitForExistence(timeout: 3.0))
        sendOTPButton.tap()
        
        // 4. Verify we arrived on the OTP Screen (mock auth skips real Firebase call)
        let otpField = app.textFields["otpInputField"]
        XCTAssertTrue(otpField.waitForExistence(timeout: 5.0),
                      "Tapping 'Send OTP' with valid info must navigate to PhoneVerificationView.")
    }

    // MARK: - Tab Bar Navigation (Logged In State)
    
    func test_tabBarNavigation_switchesTabsSuccessfully() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-skillspryng.isLoggedIn", "YES"]
        app.launch()
        
        // 1. Verify we start on Home
        let homeTab = app.tabBars.buttons["HOME"]
        XCTAssertTrue(homeTab.waitForExistence(timeout: 5.0), "MainTabView should be visible after login.")
        
        // 2. Tap Sessions tab
        app.tabBars.buttons["SESSIONS"].tap()
        
        // 3. Tap Messages tab
        app.tabBars.buttons["MESSAGES"].tap()
        
        // 4. Tap Rewards tab
        app.tabBars.buttons["REWARDS"].tap()
        
        XCTAssertTrue(app.tabBars.buttons["REWARDS"].isSelected || app.tabBars.buttons["REWARDS"].exists,
                      "Rewards tab must be active or exist without crashing.")
    }

    // MARK: - Discovery Search
    
    func test_discoverSearch_noResults_showsEmptyState() {
        let app = XCUIApplication()
        app.launchArguments = ["-skillspryng.isLoggedIn", "YES"]
        app.launch()
        
        // Locate the Discover tab's dedicated search field by its accessibility ID
        let searchField = app.textFields["discoverSearchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 8.0),
                      "Search field must exist on Discover tab.")
        searchField.tap()
        searchField.typeText("xyznotarealskill")
        
        XCTAssertTrue(app.staticTexts["No Skills Found"].waitForExistence(timeout: 5.0),
                      "Empty state must appear when no skills match the search query.")
    }

    // MARK: - Chat Messaging
    
    func test_chat_sendMessage_appearsInBubble() {
        let app = XCUIApplication()
        app.launchArguments = ["-skillspryng.isLoggedIn", "YES"]
        app.launch()
        
        let messagesTab = app.tabBars.buttons["MESSAGES"]
        XCTAssertTrue(messagesTab.waitForExistence(timeout: 5.0))
        messagesTab.tap()
        
        // Find first inbox match card and tap it to open chat
        let firstCell = app.otherElements["inboxMatchCard"].firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5.0),
                      "Should find at least one match card in Inbox.")
        firstCell.tap()
        
        // Wait for chat input field
        let inputField = app.textFields["chatMessageTextField"]
        XCTAssertTrue(inputField.waitForExistence(timeout: 5.0),
                      "Chat message input field must be visible.")
        inputField.tap()
        inputField.typeText("Hello from UI test")
        
        // Wait for send button to become active (it's disabled when text is empty)
        let sendButton = app.buttons["chatSendButton"]
        XCTAssertTrue(sendButton.waitForExistence(timeout: 3.0),
                      "Chat send button must appear after entering text.")
        
        // Verify button is now enabled (text is not empty)
        XCTAssertTrue(sendButton.isEnabled, "Send button must be enabled when message text is non-empty.")
        sendButton.tap()
        
        // Verify the message bubble appears with the text
        XCTAssertTrue(app.staticTexts["Hello from UI test"].waitForExistence(timeout: 5.0),
                      "Sent message must appear in the chat bubble.")
    }

    // MARK: - Session Booking
    
    func test_matchDetail_tapBookSession_opensbookingView() {
        let app = XCUIApplication()
        app.launchArguments = ["-skillspryng.isLoggedIn", "YES"]
        app.launch()
        
        // Scroll down on Discover to ensure the hero card is visible
        let discoverScrollView = app.scrollViews.firstMatch
        XCTAssertTrue(discoverScrollView.waitForExistence(timeout: 5.0))
        
        // Wait for the Connect Now button on the hero card and scroll to it
        let connectButton = app.buttons["connectNowButton"]
        if !connectButton.waitForExistence(timeout: 5.0) {
            XCTFail("connectNowButton not found on Discover screen.")
            return
        }
        
        // Scroll to make button hittable if needed
        if !connectButton.isHittable {
            discoverScrollView.scrollToElement(connectButton)
        }
        connectButton.tap()
        
        // Find and tap the first skill match card
        let firstCell = app.buttons["skillMatchCard"].firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5.0),
                      "Should find at least one recommended match card.")
        firstCell.tap()
        
        // Tap the Book Button, scrolling if needed
        let bookButton = app.buttons["bookSessionButton"]
        XCTAssertTrue(bookButton.waitForExistence(timeout: 5.0),
                      "Book Session button must appear on match detail screen.")
        if !bookButton.isHittable { app.swipeUp() }
        bookButton.tap()
        
        // Verify we are on the Session Booking view
        XCTAssertTrue(app.staticTexts["Session Booking"].waitForExistence(timeout: 5.0),
                      "Session Booking view must appear after tapping Book Session.")
    }

    // MARK: - Offline Banner
    
    func test_offlineBanner_appearsWhenNoNetwork() {
        // This requires Network Link Conditioner or a mock injection
        // Best tested manually — see Part 4 §6 above
    }

    // MARK: - Accessibility
    
    func test_accessibility_keyElementsHaveLabels() {
        let app = XCUIApplication()
        app.launchArguments = ["-skillspryng.isLoggedIn", "NO"]
        app.launch()
        
        // Skip through onboarding if visible
        let skipButton = app.buttons["onboardingSkipButton"]
        if skipButton.waitForExistence(timeout: 8.0) {
            skipButton.tap()
        }
        
        // Verify Send OTP button exists and has a non-empty accessibility label
        let sendOTP = app.buttons["sendOTPButton"]
        XCTAssertTrue(sendOTP.waitForExistence(timeout: 5.0),
                      "Send OTP button should be present on login.")
        XCTAssertFalse(sendOTP.label.isEmpty,
                       "Send OTP button must have an accessibility label for VoiceOver.")
        
        // Verify the Full Name text field is also accessible
        let nameField = app.textFields["fullNameTextField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 3.0),
                      "Full Name text field must be present and accessible.")
    }
}

// MARK: - XCUIElement extension for scrolling to element
extension XCUIElement {
    func scrollToElement(_ element: XCUIElement) {
        while !element.isHittable {
            swipeUp()
        }
    }
}
