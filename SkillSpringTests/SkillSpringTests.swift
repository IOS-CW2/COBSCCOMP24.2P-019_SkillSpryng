//
//  SkillSpringTests.swift
//  SkillSpringTests
//
//  Created by COBSCCOMP24.2P-019 on 2026-03-30.
//

import Testing

import XCTest
import MapKit
import FirebaseCore
@testable import SkillSpring

final class SkillSpringTests: XCTestCase {
    // Temporarily disabled to bypass crashes
    func testAuthViewModelOTPFlow() async {
        let mockFirebase = MockFirebaseManager()
        let viewModel = await AuthViewModel(firebaseService: mockFirebase)
        
        await MainActor.run {
            viewModel.fullName = "Test User"
            viewModel.phoneNumber = "1234567890"
            viewModel.sendOTP()
        }
        
        // Wait for the Task inside sendOTP to execute
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        let verificationID = await viewModel.verificationID
        XCTAssertEqual(verificationID, "MOCK_VERIFICATION_ID")
        let navigateToOTP = await viewModel.navigateToOTP
        XCTAssertTrue(navigateToOTP)
    }

    func testSkillSetupViewModelSaving() async {
        let mockFirebase = MockFirebaseManager()
        let viewModel = await SkillSetupViewModel(firebaseService: mockFirebase)
        
        await MainActor.run {
            viewModel.toggleTeachSkill("Swift")
            viewModel.experienceLevel = .expert
            viewModel.saveProfile(fullName: "Test User", phoneNumber: "1234567890")
        }
        
        // Wait for the Task inside saveProfile to execute
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        let isComplete = await viewModel.isSetupComplete
        XCTAssertTrue(isComplete)
        XCTAssertEqual(mockFirebase.mockUser?.fullName, "Test User")
        XCTAssertEqual(mockFirebase.mockUser?.experienceLevel, "Expert")
    }

    func testMapViewModelInitialization() {
        let mapViewModel = MapViewModel()
        XCTAssertEqual(mapViewModel.locationName, "Finding location...")
        XCTAssertFalse(mapViewModel.nearbySkills.isEmpty)
    }
}
