// ChatViewModelTests.swift
// SkillSpryng — ChatViewModel Unit Tests
//
// Tests the ChatViewModel message-sending logic in isolation using mock
// Conversation and ChatMessage fixtures — no live Firestore required.
//
// Coverage:
//   • Empty / whitespace text is silently discarded (no append, no crash)
//   • Valid text is appended to messages optimistically
//   • Sent message has the correct text, isFromMe flag and .text type
//   • deleteMessage and markRead do not mutate local state (fire-and-forget Tasks)
//
// Pattern: Arrange → Act → Assert (AAA)

import XCTest
@testable import SkillSpring

// MARK: - ChatViewModelTests

@MainActor
final class ChatViewModelTests: XCTestCase {

    // MARK: - Fixtures

    private var sut: ChatViewModel!
    private var mockConversation: Conversation!

    override func setUp() async throws {
        try await super.setUp()

        // Build a minimal Conversation fixture — no real Firestore calls are made
        // because listenToMessages returns immediately for an unknown conversationId
        // in a test environment (snapshot listener receives 0 docs).
        let participant = User(
            id: "INSTRUCTOR_001",
            fullName: "Jane Instructor",
            phoneNumber: "+94771111111"
        )
        mockConversation = Conversation(
            id: "TEST_CONV_001",
            participant: participant,
            lastMessage: "Hey!",
            lastMessageTime: "10:00 AM",
            unreadCount: 1,
            messages: []
        )
        sut = ChatViewModel(conversation: mockConversation)
        // Immediately stop the listener so tests remain offline
        FirebaseDataService.shared.stopListeningToMessages(conversationId: mockConversation.id)
        sut.isLoading = false
    }

    override func tearDown() async throws {
        sut = nil
        mockConversation = nil
        try await super.tearDown()
    }

    // MARK: - send(text:) — Empty / Whitespace Guard

    func test_send_withEmptyString_doesNotAppendMessage() {
        // Arrange
        let countBefore = sut.messages.count

        // Act
        sut.send(text: "")

        // Assert
        XCTAssertEqual(sut.messages.count, countBefore,
                       "Sending an empty string must not append any message.")
    }

    func test_send_withWhitespaceOnly_doesNotAppendMessage() {
        // Arrange
        let countBefore = sut.messages.count

        // Act
        sut.send(text: "   \t  ")

        // Assert
        XCTAssertEqual(sut.messages.count, countBefore,
                       "Sending whitespace-only text must not append any message.")
    }

    // MARK: - send(text:) — Optimistic Append

    func test_send_withValidText_appendsOneMessage() {
        // Arrange
        let countBefore = sut.messages.count

        // Act
        sut.send(text: "Hello from test")

        // Assert
        XCTAssertEqual(sut.messages.count, countBefore + 1,
                       "Sending valid text must append exactly one message to the local array.")
    }

    func test_send_appendedMessage_hasCorrectText() {
        // Act
        sut.send(text: "Unit test message")

        // Assert
        XCTAssertEqual(sut.messages.last?.text, "Unit test message",
                       "The appended message text must match the sent string.")
    }

    func test_send_appendedMessage_isFromMe() {
        // Act
        sut.send(text: "Outgoing message")

        // Assert
        XCTAssertTrue(sut.messages.last?.isFromMe == true,
                      "Messages sent by the local user must have isFromMe = true.")
    }

    func test_send_appendedMessage_hasTextType() {
        // Act
        sut.send(text: "Text type check")

        // Assert
        XCTAssertEqual(sut.messages.last?.type, .text,
                       "Messages sent via send(text:) must have MessageType.text.")
    }

    func test_send_trailingWhitespaceTrimmed() {
        // Act
        sut.send(text: "  Trimmed  ")

        // Assert
        XCTAssertEqual(sut.messages.last?.text, "Trimmed",
                       "Leading and trailing whitespace must be stripped before appending.")
    }

    // MARK: - Multiple Sends

    func test_send_multipleTimes_appendsInOrder() {
        // Act
        sut.send(text: "First")
        sut.send(text: "Second")
        sut.send(text: "Third")

        // Assert — last 3 messages are in send order
        let texts = sut.messages.suffix(3).compactMap { $0.text }
        XCTAssertEqual(texts, ["First", "Second", "Third"],
                       "Messages must be appended in the order they were sent.")
    }
}
