import Foundation

struct Conversation: Identifiable, Codable {
    var id: String = UUID().uuidString
    let participant: User
    let lastMessage: String
    let lastMessageTime: String
    let unreadCount: Int
    let messages: [ChatMessage]
}
