import Foundation

// MARK: - MockDataProvider + Messages
// All Conversation and ChatMessage mock data used in NotificationsView and ChatDetailView.

extension MockDataProvider {

    var mockConversations: [Conversation] {
        let marcus = User(id: "marcus", fullName: "Marcus Chen",   phoneNumber: "123456789", skillsToTeach: ["Python", "Algorithms"], bio: "Senior Dev",         profileImageURL: "instructor1")
        let aria   = User(id: "aria",   fullName: "Aria Sterling", phoneNumber: "987654321", skillsToTeach: ["Creative Writing"],    bio: "Author",            profileImageURL: "instructor2")
        let sim    = User(id: "sim",    fullName: "Sim V",         phoneNumber: "555555555", skillsToTeach: ["UI/UX Design"],        bio: "Product Designer",  profileImageURL: "instructor1")

        return [
            // MARK: Marcus — active thread with image and attachment
            Conversation(
                participant: marcus,
                lastMessage: "Try refactoring this section using a lambda function. It'll make it much cleaner.",
                lastMessageTime: "10:48 AM",
                unreadCount: 0,
                messages: [
                    ChatMessage(
                        text: "Hey! I just reviewed your progress on the advanced Python module. Your logic in the recursion exercise was impressive. 🚀",
                        timestamp: Date().addingTimeInterval(-3600),
                        isFromMe: false, type: .text, imageName: nil, fileName: nil, fileSize: nil
                    ),
                    ChatMessage(
                        text: "Thanks Marcus! It took a few tries to get the base case right, but it finally clicked.",
                        timestamp: Date().addingTimeInterval(-3400),
                        isFromMe: true, type: .text, imageName: nil, fileName: nil, fileSize: nil
                    ),
                    ChatMessage(
                        text: nil,
                        timestamp: Date().addingTimeInterval(-3200),
                        isFromMe: false, type: .image, imageName: "course_python", fileName: nil, fileSize: nil
                    ),
                    ChatMessage(
                        text: "Try refactoring this section using a lambda function. It'll make it much cleaner.",
                        timestamp: Date().addingTimeInterval(-3000),
                        isFromMe: false, type: .text, imageName: nil, fileName: nil, fileSize: nil
                    ),
                    ChatMessage(
                        text: nil,
                        timestamp: Date().addingTimeInterval(-2800),
                        isFromMe: true, type: .attachment, imageName: nil, fileName: "Refactored_Logic.pdf", fileSize: "1.2 MB • PDF"
                    )
                ]
            ),

            // MARK: Aria — yesterday, no thread loaded
            Conversation(
                participant: aria,
                lastMessage: "Thanks for the resources you shared yesterday!",
                lastMessageTime: "YESTERDAY",
                unreadCount: 0,
                messages: []
            ),

            // MARK: Sim — recent, unread
            Conversation(
                participant: sim,
                lastMessage: "The session on UI/UX was really helpful.",
                lastMessageTime: "2MIN AGO",
                unreadCount: 1,
                messages: []
            )
        ]
    }
}
