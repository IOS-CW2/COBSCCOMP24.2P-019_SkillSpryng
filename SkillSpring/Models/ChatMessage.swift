import Foundation

/// Types of content a chat message can contain.
enum MessageType: String, Codable {
    case text = "text"
    case image = "image"
    case attachment = "attachment"
}

/// A single message in a chat conversation.
/// Can contain text, images, or file attachments.
struct ChatMessage: Identifiable, Codable {
    var id: String = UUID().uuidString
    let text: String?
    let timestamp: Date
    /// True if this message was sent by the current user.
    let isFromMe: Bool
    let type: MessageType
    let imageName: String?
    let fileName: String?
    let fileSize: String?
    var isDeleted: Bool? = false
    
    /// Formats the timestamp into a readable time string (e.g., "2:30 PM").
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: timestamp)
    }
}
