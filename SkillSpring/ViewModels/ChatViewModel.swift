import Foundation
import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth

// MARK: - ChatViewModel
// Manages a live message thread backed by a Firestore snapshot listener.
// Architecture: ChatDetailView → ChatViewModel → FirebaseDataService → Firestore

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

    func deleteMessage(_ message: ChatMessage) {
        Task {
            await FirebaseDataService.shared.deleteMessage(message.id, conversationId: conversation.id)
        }
    }

    // MARK: - Mark Read

    func markRead(_ message: ChatMessage) {
        guard !message.isFromMe else { return }
        Task {
            await FirebaseDataService.shared.markMessageRead(message.id, conversationId: conversation.id)
        }
    }

    // MARK: - Private Helpers

    private func showTypingIndicator() {
        withAnimation(.easeInOut(duration: 0.3)) { isTyping = true }
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            withAnimation(.easeInOut(duration: 0.3)) { isTyping = false }
        }
    }
}
