import Foundation
import Combine

// MARK: - DiscoverViewModel
// Drives DiscoverView — skill data loaded from Firestore via FirebaseDataService.

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

    func loadData() async {
        isLoading = true
        async let skills    = FirebaseDataService.shared.fetchRecommendedSkills()
        async let profs     = FirebaseDataService.shared.fetchProfiles()
        (recommendedSkills, profiles) = await (skills, profs)
        isLoading = false
    }

    // MARK: - Derived

    var filteredSkills: [RecommendedSkill] {
        let byCat = selectedCategory == "All Learners"
            ? recommendedSkills
            : recommendedSkills.filter { $0.category.localizedCaseInsensitiveContains(selectedCategory) }
        guard !searchText.isEmpty else { return byCat }
        return byCat.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.instructor.localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: - Match Actions (called from InboxMatchCard)

    func acceptIncomingMatch(profile: MatchProfile) async {
        await FirebaseDataService.shared.acceptIncomingMatch(fromUserId: profile.id)
        await loadData()
    }

    func declineIncomingMatch(profile: MatchProfile) async {
        await FirebaseDataService.shared.declineIncomingMatch(fromUserId: profile.id)
        await loadData()
    }

    func cancelSentMatch(profile: MatchProfile) async {
        await FirebaseDataService.shared.cancelSentMatch(toUserId: profile.id)
        await loadData()
    }
}
