import Foundation
import Combine

// MARK: - RewardsViewModel
// Drives RewardsTabView, LeaderboardView, AnalyticsView, WalletView.
// All data loaded from Firestore via FirebaseDataService.

@MainActor
/// Manages reward-related data for the Rewards tab.
///
/// Loads leaderboard standings, badges, milestones, missions, mastery progress,
/// credit packs, and analytics stats from Firestore.
final class RewardsViewModel: ObservableObject {

    // MARK: - Published State

    @Published var leaderboard: [LeaderboardEntry] = []
    @Published var rewardBadges: [RewardBadge] = []
    @Published var milestones: [Milestone] = []
    @Published var skillMissions: [SkillMission] = []
    
    // Default empty objects while fetching
    @Published var masteryData: MasteryPoints = MasteryPoints(total: 0, level: 0, progressTowardsNextLevel: 0)
    @Published var creditPacks: [CreditPack] = []
    @Published var topCurators: [LeaderboardEntry] = []
    @Published var analyticsData: AnalyticsData = AnalyticsData(streakDays: 0, sessionsCount: 0, focusHours: 0, skillsPro: 0, karmaPoints: 0, growthHistory: [], skillProgress: [])

    @Published var isLoading: Bool = false

    // MARK: - Init

    init() {
        Task { await loadData() }
    }

    func loadData() async {
        /// Loads all rewards and gamification data in parallel to keep the UI responsive.
        isLoading = true
        
        // Fire parallel requests 
        async let ldb    = FirebaseDataService.shared.fetchLeaderboard()
        async let badges = FirebaseDataService.shared.fetchRewardBadges()
        async let miles  = FirebaseDataService.shared.fetchMilestones()
        async let misses = FirebaseDataService.shared.fetchSkillMissions()
        async let mast   = FirebaseDataService.shared.fetchMasteryData()
        async let packs  = FirebaseDataService.shared.fetchCreditPacks()
        async let anls   = FirebaseDataService.shared.fetchAnalyticsData()
        
        // Note: topCurators can technically just filter the overall leaderboard, 
        // but for now we pull them out of mock if needed. FetchLeaderboard already returns them.
        
        (leaderboard, rewardBadges, milestones, skillMissions, masteryData, creditPacks, analyticsData) = await (ldb, badges, miles, misses, mast, packs, anls)
        
        // Top curators are the highest-ranked entries
        topCurators = Array(leaderboard.prefix(3))
        
        isLoading = false
    }
}
