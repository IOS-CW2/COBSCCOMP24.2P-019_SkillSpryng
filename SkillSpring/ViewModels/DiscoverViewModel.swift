import Foundation
import Combine

/// Drives the Discover tab, loading skill recommendations and match profiles.
///
/// Supports search, category filtering, and match request actions from the inbox.
@MainActor
final class DiscoverViewModel: ObservableObject {

    // MARK: - Published State

    @Published var searchText: String = ""
    @Published var selectedCategory: String = "All Learners"
    @Published var isLoading: Bool = false

    @Published var navigateToCourses: Bool = false
    @Published var navigateToSkillMatches: Bool = false
    @Published var navigateToMap: Bool = false

    let categories = ["All Learners", "Design", "Coding", "Marketing", "Arts", "Music"]

    // MARK: - Data (loaded from Firestore, fallback to mock)

    @Published var recommendedSkills: [RecommendedSkill] = []
    @Published var profiles: [MatchProfile] = []

    // MARK: - Init

    init() {
        Task { await loadData() }
    }

    // MARK: - Data Loading

    /// Loads recommended skills and public match profiles in parallel.
    /// Falls back to mock data if Firestore returns no results.
    func loadData() async {
        isLoading = true
        async let skills    = FirebaseDataService.shared.fetchRecommendedSkills()
        async let profs     = FirebaseDataService.shared.fetchProfiles()
        (recommendedSkills, profiles) = await (skills, profs)
        isLoading = false
    }

    /// Refreshes the profiles from Firestore.
    func refreshProfiles() async {
        profiles = await FirebaseDataService.shared.fetchProfiles()
    }

    // MARK: - Derived

    /// Filtered skill recommendations based on selected category and search text.
    var filteredSkills: [RecommendedSkill] {
        let search = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let filtered = selectedCategory == "All Learners"
            ? recommendedSkills
            : recommendedSkills.filter { $0.category.localizedCaseInsensitiveContains(selectedCategory) }

        guard !search.isEmpty else { return filtered }
        return filtered.filter {
            $0.title.localizedCaseInsensitiveContains(search) ||
            $0.instructor.localizedCaseInsensitiveContains(search) ||
            $0.category.localizedCaseInsensitiveContains(search) ||
            $0.price.localizedCaseInsensitiveContains(search)
        }
    }

    // MARK: - Match Actions (called from InboxMatchCard)

    /// Accepts an incoming match request and refreshes discovery data.
    func acceptIncomingMatch(profile: MatchProfile) async {
        await FirebaseDataService.shared.acceptIncomingMatch(fromUserId: profile.id)
        await loadData()
    }

    /// Declines an incoming match request and refreshes the profile list.
    func declineIncomingMatch(profile: MatchProfile) async {
        await FirebaseDataService.shared.declineIncomingMatch(fromUserId: profile.id)
        await loadData()
    }

    /// Cancels a previously sent match request and refreshes discovery data.
    func cancelSentMatch(profile: MatchProfile) async {
        await FirebaseDataService.shared.cancelSentMatch(toUserId: profile.id)
        await loadData()
    }
}
