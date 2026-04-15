import Foundation
import SwiftUI
import Combine

// MARK: - ChatViewModel
// Manages the message thread state for ChatDetailView.
// Follows the MVVM pattern — the View owns no business logic.
//
// BACKEND INTEGRATION NOTE:
// When Firestore is wired, replace the local `messages` array with a
// real-time listener on:
//   db.collection("conversations/\(conversationId)/messages")
//     .order(by: "timestamp")
//     .addSnapshotListener { ... }

@MainActor
final class ChatViewModel: ObservableObject {

    // MARK: - Published State (drives the View)

    /// The live message thread seeded from the conversation snapshot.
    @Published var messages: [ChatMessage]

    /// Controls the "is typing…" indicator.
    @Published var isTyping: Bool = false

    /// The conversation this ViewModel manages.
    let conversation: Conversation

    // MARK: - Init

    init(conversation: Conversation) {
        self.conversation = conversation
        self.messages = conversation.messages
    }

    // MARK: - Public Intent

    /// Appends an outgoing message and briefly shows the typing indicator.
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
        messages.append(outgoing)
        HapticManager.light()
        showTypingIndicator()
    }

    // MARK: - Private Helpers

    /// Shows the "typing…" indicator for 1.5 s then hides it.
    private func showTypingIndicator() {
        withAnimation(.easeInOut(duration: 0.3)) { isTyping = true }
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) { isTyping = false }
            }
        }
    }
}
