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
    func testMockDataProviderConsistency() {
        let provider = MockDataProvider.shared
        XCTAssertEqual(provider.elenaProfile.name, "Elena Rodriguez")
        XCTAssertEqual(provider.matchProfiles.count, 2)
        XCTAssertEqual(provider.recommendedSkills.count, 3)
    }

    func testAnalyticsDataLogic() {
        let data = MockDataProvider.shared.analyticsData
        XCTAssertEqual(data.streakDays, 7)
        XCTAssertEqual(data.growthHistory.count, 7)
        XCTAssertTrue(data.karmaPoints > 1000)
    }

    func testMapViewModelInitialization() {
        let mapViewModel = MapViewModel()
        XCTAssertEqual(mapViewModel.locationName, "Finding location...")
        XCTAssertFalse(mapViewModel.nearbySkills.isEmpty)
    }
}
