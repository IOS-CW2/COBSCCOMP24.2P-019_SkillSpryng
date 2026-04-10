import Foundation

enum MessageType {
    case text
    case image
    case attachment
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String?
    let timestamp: Date
    let isFromMe: Bool
    let type: MessageType
    let imageName: String?
    let fileName: String?
    let fileSize: String?
    
    // Helper to format timestamp
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: timestamp)
    }
}
