import Foundation

struct Conversation: Identifiable {
    let id = UUID()
    let participant: User
    let lastMessage: String
    let lastMessageTime: String
    let unreadCount: Int
    let messages: [ChatMessage]
}
