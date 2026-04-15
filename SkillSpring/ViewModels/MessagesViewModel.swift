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
            .filter { matchesSearch($0) }
    }

    var yesterdayConversations: [Conversation] {
        allConversations
            .filter { $0.lastMessageTime == "YESTERDAY" }
            .filter { matchesSearch($0) }
    }

    var isTodayEmpty: Bool {
        !searchText.isEmpty && todayConversations.isEmpty
    }

    private func matchesSearch(_ conversation: Conversation) -> Bool {
        guard !searchText.isEmpty else { return true }
        return conversation.participant.fullName.localizedCaseInsensitiveContains(searchText) ||
               conversation.lastMessage.localizedCaseInsensitiveContains(searchText)
    }
}
