import Foundation

/// Represents a conversation thread between the current user and another user.
/// Contains the participant info, message history, and last message preview.
struct Conversation: Identifiable, Codable {
    var id: String = UUID().uuidString
    /// The other user in this conversation.
    let participant: User
    /// Preview of the most recent message.
    let lastMessage: String
    /// Timestamp of the last message (e.g., "2 hours ago").
    let lastMessageTime: String
    /// Number of unread messages in this conversation.
    let unreadCount: Int
    /// Full message history for this conversation.
    let messages: [ChatMessage]
}
