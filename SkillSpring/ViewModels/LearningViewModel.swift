import Foundation
import Combine

/// Drives the Learning tab by loading course and event content from Firestore.
///
/// Manages featured courses, popular classes, personal learning path, and upcoming events.
@MainActor
final class LearningViewModel: ObservableObject {

    // MARK: - Published State

    @Published var featuredCourses: [Course] = []
    @Published var popularCourses: [Course] = []
    @Published var learningPath: [Course] = []
    @Published var upcomingEvents: [Event] = []
    @Published var isLoading: Bool = false

    @Published var selectedTab: String = "Courses"
    @Published var selectedCategory: String = "All"
    let categories = ["All", "Design", "Coding", "Music", "Languages", "Business"]

    // MARK: - Init

    init() {
        Task { await loadData() }
    }

    // MARK: - Data Loading

    /// Loads all learning content concurrently for the Home Learning screen.
    func loadData() async {
        isLoading = true
        async let courses   = FirebaseDataService.shared.fetchFeaturedCourses()
        async let popular   = FirebaseDataService.shared.fetchPopularCourses()
        async let paths     = FirebaseDataService.shared.fetchLearningPath()
        async let events    = FirebaseDataService.shared.fetchUpcomingEvents()

        (featuredCourses, popularCourses, learningPath, upcomingEvents) = await (courses, popular, paths, events)
        isLoading = false
    }

    // MARK: - Derived

    var happeningSoonEvent: Event? { upcomingEvents.first }

    /// Returns featured courses filtered by category selection.
    var filteredFeatured: [Course] {
        selectedCategory == "All"
            ? featuredCourses
            : featuredCourses.filter { $0.category.localizedCaseInsensitiveContains(selectedCategory) }
    }
}
