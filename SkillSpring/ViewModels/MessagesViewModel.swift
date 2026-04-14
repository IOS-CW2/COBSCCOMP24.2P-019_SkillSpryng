import Foundation
import Combine

// MARK: - MessagesViewModel
// Drives NotificationsView — owns the conversation list and search/filter logic.
// The View should never reference MockDataProvider directly.

@MainActor
final class MessagesViewModel: ObservableObject {

    // MARK: - Published State

    @Published var searchText: String = ""
    @Published var selectedFilter: String = "All"

    let filters = ["All", "Unread", "Matches", "Groups"]

    // MARK: - Data Source

    /// All conversations loaded from the mock service.
    /// Replace `MockDataProvider.shared.mockConversations` with a
    /// Firestore listener on `db.collection("conversations").whereField("participants", arrayContains: userId)`.
    private var allConversations: [Conversation] = MockDataProvider.shared.mockConversations

    // MARK: - Derived (computed, reactive)

    /// Today's conversations — filtered by name and last message.
    var todayConversations: [Conversation] {
        allConversations.filter {
            ($0.participant.fullName == "Marcus Chen" || $0.participant.fullName == "Sim V") &&
            matchesSearch($0)
        }
    }

    /// Yesterday's conversations.
    var yesterdayConversations: [Conversation] {
        allConversations.filter {
            $0.participant.fullName == "Aria Sterling" &&
            matchesSearch($0)
        }
    }

    /// True when a search is active and no results are found.
    var isTodayEmpty: Bool {
        !searchText.isEmpty && todayConversations.isEmpty
    }

    // MARK: - Private Helpers

    private func matchesSearch(_ conversation: Conversation) -> Bool {
        guard !searchText.isEmpty else { return true }
        return conversation.participant.fullName.localizedCaseInsensitiveContains(searchText) ||
               conversation.lastMessage.localizedCaseInsensitiveContains(searchText)
    }
}
