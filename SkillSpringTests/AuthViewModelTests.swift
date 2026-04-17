// AuthViewModelTests.swift
// SkillSpryng Unit Tests
//
// Tests the AuthViewModel OTP state machine using a MockFirebaseService
// so no live Firebase connection is needed.
//
// Run: Cmd+U   ·   Pattern: Arrange → Act → Assert (AAA)

import XCTest
import Combine
@testable import SkillSpring

// MARK: - AuthViewModelTests

@MainActor
final class AuthViewModelTests: XCTestCase {

    private var sut: AuthViewModel!
    private var mockService: MockFirebaseManager!
    private var mockSeeder: MockDataSeeder!
    private var mockDataService: MockDataService!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() async throws {
        try await super.setUp()
        mockService   = MockFirebaseManager()
        mockSeeder    = MockDataSeeder()
        mockDataService = MockDataService()
        sut           = AuthViewModel(firebaseService: mockService,
                                      seederService: mockSeeder,
                                      dataService: mockDataService)
        cancellables  = []
    }

    override func tearDown() async throws {
        sut          = nil
        mockService  = nil
        cancellables = nil
        try await super.tearDown()
    }

    // MARK: - sendOTP

    func test_sendOTP_withEmptyPhone_setsErrorMessage() {
        // Arrange
        sut.phoneNumber = ""

        // Act
        sut.sendOTP()

        // Assert
        XCTAssertNotNil(sut.errorMessage,
                        "errorMessage must be set when phoneNumber is empty.")
        XCTAssertFalse(sut.navigateToOTP,
                       "Should not navigate to OTP with empty phone number.")
    }

    func test_sendOTP_withValidPhone_setsIsLoading() {
        // Arrange
        sut.phoneNumber = "+94771234567"
        mockService.sendOTPResult = .success("VERIFICATION_ID_001")

        let exp = expectation(description: "isLoading becomes true")
        sut.$isLoading
            .dropFirst()            // skip initial false
            .first { $0 }          // wait for true
            .sink { _ in exp.fulfill() }
            .store(in: &cancellables)

        // Act
        sut.sendOTP()

        // Assert — loading starts immediately
        wait(for: [exp], timeout: 1.0)
    }

    func test_sendOTP_onSuccess_setsNavigateToOTP() async {
        // Arrange
        sut.phoneNumber = "+94771234567"
        mockService.sendOTPResult = .success("VERIFICATION_ID_001")

        // Act
        sut.sendOTP()
        // Allow the Task to complete
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Assert
        XCTAssertEqual(sut.verificationID, "VERIFICATION_ID_001")
        XCTAssertTrue(sut.navigateToOTP,
                      "navigateToOTP must be true after a successful OTP send.")
    }

    func test_sendOTP_onFailure_setsErrorMessage() async {
        // Arrange
        sut.phoneNumber = "+94771234567"
        mockService.sendOTPResult = .failure(NSError(domain: "Auth", code: -1,
                                                      userInfo: [NSLocalizedDescriptionKey: "Invalid number"]))

        // Act
        sut.sendOTP()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Assert
        XCTAssertNotNil(sut.errorMessage,
                        "errorMessage must be set on OTP send failure.")
        XCTAssertFalse(sut.navigateToOTP,
                       "navigateToOTP must remain false on failure.")
    }

    // MARK: - verifyCode

    func test_verifyCode_withoutVerificationID_setsErrorMessage() {
        // Arrange — verificationID is nil by default
        sut.verificationCode = "123456"

        // Act
        sut.verifyCode()

        // Assert
        XCTAssertNotNil(sut.errorMessage,
                        "errorMessage must be set when verificationID is missing.")
    }

    func test_verifyCode_withEmptyCode_setsErrorMessage() {
        // Arrange
        sut.verificationID   = "VERIFICATION_ID_001"
        sut.verificationCode = ""

        // Act
        sut.verifyCode()

        // Assert
        XCTAssertNotNil(sut.errorMessage,
                        "errorMessage must be set when verificationCode is empty.")
    }
    
    func test_verifyCode_withNewUser_navigatesToSkillSetup() async {
        // Arrange
        sut.verificationID = "VERIFICATION_ID_001"
        sut.verificationCode = "123456"
        mockService.verifyOTPResult = .success(AuthResultProxy(uid: "NEW_UID", isNewUser: true))
        
        let exp = expectation(description: "navigateToSkillSetup becomes true")
        sut.$navigateToSkillSetup
            .dropFirst()
            .first { $0 }
            .sink { _ in exp.fulfill() }
            .store(in: &cancellables)
            
        // Act
        sut.verifyCode()
        
        // Assert
        await fulfillment(of: [exp], timeout: 1.0)
        XCTAssertTrue(sut.navigateToSkillSetup)
        XCTAssertFalse(sut.navigateToSuccess)
    }
    
    func test_verifyCode_withExistingUser_navigatesToHome() async {
        // Arrange
        sut.verificationID = "VERIFICATION_ID_001"
        sut.verificationCode = "123456"
        mockService.verifyOTPResult = .success(AuthResultProxy(uid: "OLD_UID", isNewUser: false))
        
        let exp = expectation(description: "navigateToSuccess becomes true")
        sut.$navigateToSuccess
            .dropFirst()
            .first { $0 }
            .sink { _ in exp.fulfill() }
            .store(in: &cancellables)
            
        // Act
        sut.verifyCode()
        
        // Assert
        await fulfillment(of: [exp], timeout: 1.0)
        XCTAssertTrue(sut.navigateToSuccess)
        XCTAssertFalse(sut.navigateToSkillSetup)
    }
}


