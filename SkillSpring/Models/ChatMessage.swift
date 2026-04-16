import Foundation

enum MessageType: String, Codable {
    case text = "text"
    case image = "image"
    case attachment = "attachment"
}

struct ChatMessage: Identifiable, Codable {
    var id: String = UUID().uuidString
    let text: String?
    let timestamp: Date
    let isFromMe: Bool
    let type: MessageType
    let imageName: String?
    let fileName: String?
    let fileSize: String?
    var isDeleted: Bool? = false
    
    // Helper to format timestamp
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: timestamp)
    }
}
