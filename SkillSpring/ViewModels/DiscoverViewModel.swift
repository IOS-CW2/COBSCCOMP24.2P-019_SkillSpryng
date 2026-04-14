import Foundation
import Combine

// MARK: - DiscoverViewModel
// Drives DiscoverView — owns skill data, category filtering, and navigation flags.
// The View should never reference MockDataProvider directly.

@MainActor
final class DiscoverViewModel: ObservableObject {

    // MARK: - Published State

    @Published var searchText: String = ""
    @Published var selectedCategory: String = "All Learners"

    @Published var navigateToCourses: Bool = false
    @Published var navigateToSkillMatches: Bool = false
    @Published var navigateToMap: Bool = false

    let categories = ["All Learners", "Design", "Coding", "Marketing", "Arts", "Music"]

    // MARK: - Data (loaded from mock service)
    // Replace with async fetch calls to FirebaseManager / API when backend is ready.

    let recommendedSkills: [RecommendedSkill] = MockDataProvider.shared.recommendedSkills

    // MARK: - Derived

    /// Skills filtered by the active category chip.
    var filteredSkills: [RecommendedSkill] {
        guard selectedCategory != "All Learners" else { return recommendedSkills }
        return recommendedSkills.filter {
            $0.category.localizedCaseInsensitiveContains(selectedCategory)
        }
    }

    /// Skills filtered by the search bar text.
    var searchFilteredSkills: [RecommendedSkill] {
        guard !searchText.isEmpty else { return filteredSkills }
        return filteredSkills.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.instructor.localizedCaseInsensitiveContains(searchText)
        }
    }
}
