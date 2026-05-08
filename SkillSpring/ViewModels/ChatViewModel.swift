import Foundation
import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth

/// Manages a live chat conversation for SkillSpryng.
///
/// Attaches a Firestore listener for incoming messages, performs optimistic
/// UI updates on send, and handles read / delete actions.
@MainActor
final class ChatViewModel: ObservableObject {

    // MARK: - Published State
    @Published var messages: [ChatMessage] = []
    @Published var isTyping: Bool = false
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?

    let conversation: Conversation

    // MARK: - Init

    init(conversation: Conversation) {
        self.conversation = conversation
        attachListener()
    }

    deinit {
        let convId = conversation.id
        Task { @MainActor in
            FirebaseDataService.shared.stopListeningToMessages(conversationId: convId)
        }
    }

    // MARK: - Real-Time Listener

    /// Subscribes to Firestore updates for the current conversation.
    /// Live messages are mirrored immediately into the `messages` array.
    private func attachListener() {
        FirebaseDataService.shared.listenToMessages(
            conversationId: conversation.id
        ) { [weak self] liveMessages in
            guard let self else { return }
            self.messages = liveMessages
            self.isLoading = false
        }
    }

    // MARK: - Send Message

    /// Sends a new chat message.
    /// Performs an optimistic UI append before persisting to Firestore.
    func send(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let outgoing = ChatMessage(
            text: trimmed,
            timestamp: Date(),
            isFromMe: true,
            type: .text,
            imageName: nil,
            fileName: nil,
            fileSize: nil
        )

        // Optimistic UI update
        messages.append(outgoing)
        HapticManager.light()
        showTypingIndicator()

        // Persist to Firestore
        Task {
            await FirebaseDataService.shared.sendMessage(outgoing, to: conversation.id)
        }
    }

    // MARK: - Delete Message (soft delete)

    /// Marks a chat message as deleted in Firestore.
    /// The UI can show a placeholder text for deleted entries.
    func deleteMessage(_ message: ChatMessage) {
        Task {
            await FirebaseDataService.shared.deleteMessage(message.id, conversationId: conversation.id)
        }
    }

    // MARK: - Mark Read

    /// Marks a received message as read in Firestore.
    /// Avoids updating messages the current user sent themself.
    func markRead(_ message: ChatMessage) {
        guard !message.isFromMe else { return }
        Task {
            await FirebaseDataService.shared.markMessageRead(message.id, conversationId: conversation.id)
        }
    }

    // MARK: - Private Helpers

    /// Shows a temporary typing indicator for 1.5 seconds.
    /// This makes outgoing sends feel more responsive and alive.
    private func showTypingIndicator() {
        withAnimation(.easeInOut(duration: 0.3)) { isTyping = true }
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            withAnimation(.easeInOut(duration: 0.3)) { isTyping = false }
        }
    }
}
