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

    private var filteredConversations: [Conversation] {
        let search = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let filtered = allConversations.filter { applyFilter($0) }

        guard !search.isEmpty else { return filtered }
        return filtered.filter {
            $0.participant.fullName.localizedCaseInsensitiveContains(search) ||
            $0.lastMessage.localizedCaseInsensitiveContains(search) ||
            $0.participant.bio.localizedCaseInsensitiveContains(search) ||
            $0.participant.skillsToTeach.joined(separator: " ").localizedCaseInsensitiveContains(search)
        }
    }

    var todayConversations: [Conversation] {
        filteredConversations.filter { $0.lastMessageTime != "YESTERDAY" }
    }

    var yesterdayConversations: [Conversation] {
        filteredConversations.filter { $0.lastMessageTime == "YESTERDAY" }
    }

    var isTodayEmpty: Bool {
        todayConversations.isEmpty
    }

    private func applyFilter(_ conversation: Conversation) -> Bool {
        switch selectedFilter {
        case "Unread":
            return conversation.unreadCount > 0
        case "Matches":
            return isMatchConversation(conversation)
        case "Groups":
            return isGroupConversation(conversation)
        default:
            return true
        }
    }

    private func isMatchConversation(_ conversation: Conversation) -> Bool {
        let searchTarget = [conversation.lastMessage, conversation.participant.bio]
            .joined(separator: " ")
            .localizedCaseInsensitiveContains("match")
        return searchTarget || conversation.participant.skillsToTeach.contains(where: { $0.localizedCaseInsensitiveContains("match") })
    }

    private func isGroupConversation(_ conversation: Conversation) -> Bool {
        let searchTarget = [conversation.lastMessage, conversation.participant.bio]
            .joined(separator: " ")
            .localizedCaseInsensitiveContains("group")
        return searchTarget
    }
}
