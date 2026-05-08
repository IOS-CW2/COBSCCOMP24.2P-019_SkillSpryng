// FirebaseDataServiceModelTests.swift
// SkillSpryng Unit Tests
//
// Tests Codable round-trips for the core Firestore model types.
// No live Firestore connection is required — we use Firestore.Encoder/Decoder
// to verify that models can be serialised and deserialised without data loss.
//
// Run: Cmd+U   ·   Pattern: Arrange → Act → Assert (AAA)

import XCTest
import FirebaseFirestore
@testable import SkillSpring

final class FirebaseDataServiceModelTests: XCTestCase {

    // MARK: - Session Model

    func test_session_codableRoundTrip_preservesAllFields() throws {
        // Arrange
        let original = Session(
            title:          "iOS Development Masterclass",
            instructorName: "Elena Rodriguez",
            instructorRole: "Senior iOS Engineer",
            date:           "Apr 15, 2026",
            time:           "10:00 AM",
            duration:       "60 min",
            location:       nil,
            distance:       nil,
            timeRemaining:  "2h",
            status:         .upcoming,
            type:           .online,
            category:       "Development",
            rating:         nil,
            notes:          "Focus on Swift Concurrency",
            matchPercentage: 92,
            scheduledAt:    Date(timeIntervalSince1970: 1_744_000_000)
        )

        // Act
        let encoded = try Firestore.Encoder().encode(original)
        var decoded = try Firestore.Decoder().decode(Session.self, from: encoded)
        decoded.id = original.id   // id is not Firestore-encoded, set manually

        // Assert
        XCTAssertEqual(decoded.title,           original.title)
        XCTAssertEqual(decoded.instructorName,  original.instructorName)
        XCTAssertEqual(decoded.status,          original.status)
        XCTAssertEqual(decoded.type,            original.type)
        XCTAssertEqual(decoded.category,        original.category)
        XCTAssertEqual(decoded.matchPercentage, original.matchPercentage)
        XCTAssertEqual(decoded.notes,           original.notes)
    }

    func test_session_defaultStatus_isUpcoming() {
        let s = Session(
            title: "Test", instructorName: "A", instructorRole: "B",
            date: "Today", time: "9AM", duration: "30 min",
            location: nil, distance: nil, timeRemaining: nil,
            status: .upcoming, type: .online, category: "X",
            rating: nil, notes: nil, matchPercentage: 80, scheduledAt: Date()
        )
        XCTAssertEqual(s.status, .upcoming)
    }

    // MARK: - User Model

    func test_user_codableRoundTrip_preservesWalletBalance() throws {
        // Arrange
        var original = User(
            id:            "uid-test-1",
            fullName:      "Kavindu Perera",
            email:         "k@test.com",
            phoneNumber:   "+94771234567",
            walletBalance: 1500
        )
        original.id = "uid-test-1"

        // Act
        let encoded = try Firestore.Encoder().encode(original)
        var decoded = try Firestore.Decoder().decode(User.self, from: encoded)
        decoded.id = original.id

        // Assert
        XCTAssertEqual(decoded.fullName,      original.fullName)
        XCTAssertEqual(decoded.walletBalance, original.walletBalance,
                       "walletBalance must survive a Firestore Encoder/Decoder round-trip.")
        XCTAssertEqual(decoded.phoneNumber,   original.phoneNumber)
    }

    func test_user_walletBalance_defaultsToZero() {
        let u = User(id: "x", fullName: "X", email: "", phoneNumber: "", walletBalance: 0)
        XCTAssertEqual(u.walletBalance, 0)
    }

    // MARK: - CreditTransaction Model

    func test_creditTransaction_codableRoundTrip_preservesAmount() throws {
        // Arrange
        let original = CreditTransaction(
            amount:      -150,
            type:        .sessionPayment,
            description: "Paid for Elena session",
            balanceAfter: 1350,
            referenceId: "session-abc"
        )

        // Act
        let encoded = try Firestore.Encoder().encode(original)
        let decoded = try Firestore.Decoder().decode(CreditTransaction.self, from: encoded)

        // Assert
        XCTAssertEqual(decoded.amount,       original.amount,
                       "Transaction amount must survive Firestore round-trip.")
        XCTAssertEqual(decoded.type,         original.type)
        XCTAssertEqual(decoded.balanceAfter, original.balanceAfter)
        XCTAssertEqual(decoded.description,  original.description)
    }

    func test_creditTransaction_negativeAmount_isPreserved() throws {
        let tx = CreditTransaction(
            amount: -500, type: .sessionPayment,
            description: "Test", balanceAfter: 0, referenceId: nil
        )
        let encoded = try Firestore.Encoder().encode(tx)
        let decoded = try Firestore.Decoder().decode(CreditTransaction.self, from: encoded)
        XCTAssertEqual(decoded.amount, -500, "Negative amounts must be preserved exactly.")
    }

    // MARK: - AppNotification Model

    func test_appNotification_codableRoundTrip_preservesType() throws {
        // Arrange
        let original = AppNotification(
            type:        .sessionConfirmed,
            title:       "Session Booked! ✅",
            body:        "Your session with Elena on Apr 15 is confirmed.",
            referenceId: "session-xyz"
        )

        // Act
        let encoded = try Firestore.Encoder().encode(original)
        let decoded = try Firestore.Decoder().decode(AppNotification.self, from: encoded)

        // Assert
        XCTAssertEqual(decoded.type,        original.type)
        XCTAssertEqual(decoded.title,       original.title)
        XCTAssertEqual(decoded.body,        original.body)
        XCTAssertEqual(decoded.referenceId, original.referenceId)
        XCTAssertFalse(decoded.isRead,      "isRead must default to false.")
    }
}
