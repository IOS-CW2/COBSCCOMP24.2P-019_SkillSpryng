import Foundation
import Combine

// MARK: - MessagesViewModel
// Drives NotificationsView — conversations loaded from Firestore via FirebaseDataService.

@MainActor
final class MessagesViewModel: ObservableObject {

    // MARK: - Published State

    @Published var searchText: String = ""
    @Published var selectedFilter: String = "All"
    @Published var isLoading: Bool = false

    let filters = ["All", "Unread", "Matches", "Groups"]

    // MARK: - Data (loaded from Firestore, fallback to mock)

    @Published private var allConversations: [Conversation] = []

    // MARK: - Init

    init() {
        Task { await loadConversations() }
    }

    // MARK: - Data Loading

    func loadConversations() async {
        isLoading = true
        allConversations = await FirebaseDataService.shared.fetchConversations()
        isLoading = false
    }

    // MARK: - Derived

    var todayConversations: [Conversation] {
        allConversations
            .filter { $0.lastMessageTime != "YESTERDAY" }
            .filter { applyFilter($0) }
            .filter { matchesSearch($0) }
    }

    var yesterdayConversations: [Conversation] {
        allConversations
            .filter { $0.lastMessageTime == "YESTERDAY" }
            .filter { applyFilter($0) }
            .filter { matchesSearch($0) }
    }

    var isTodayEmpty: Bool {
        todayConversations.isEmpty
    }

    private func applyFilter(_ conversation: Conversation) -> Bool {
        switch selectedFilter {
        case "Unread":  return conversation.unreadCount > 0
        default:        return true
        }
    }

    private func matchesSearch(_ conversation: Conversation) -> Bool {
        guard !searchText.isEmpty else { return true }
        return conversation.participant.fullName.localizedCaseInsensitiveContains(searchText) ||
               conversation.lastMessage.localizedCaseInsensitiveContains(searchText)
    }
}
