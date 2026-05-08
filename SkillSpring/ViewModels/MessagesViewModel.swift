import Foundation
import Combine

/// Manages the messages inbox and conversation filters for the Notifications tab.
///
/// Loads conversation threads, applies search and unread filters, and exposes
/// today/yesterday sections for the UI.
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

    /// Loads conversation threads from Firestore and updates loading state.
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
