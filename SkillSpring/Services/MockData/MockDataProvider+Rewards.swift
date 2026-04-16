import Foundation

// MARK: - MockDataProvider + Rewards
// Leaderboard, badges, milestones, wallet, and mission mock data
// used in RewardsView, WalletView, and PremiumView.

extension MockDataProvider {

    // MARK: Mastery
    var masteryData: MasteryPoints {
        MasteryPoints(total: 12450, level: 14, progressTowardsNextLevel: 0.85)
    }

    // MARK: Leaderboard
    var leaderboardWeekly: [LeaderboardEntry] {
        [
        LeaderboardEntry(fullName: "Marcus T.",     points: 2840, rank: 1, avatarUrl: "instructor1"),
        LeaderboardEntry(fullName: "Sarah Jenkins", points: 3120, rank: 2, avatarUrl: "instructor2", weeklyChange: 2),
        LeaderboardEntry(fullName: "Liam W.",        points: 2710, rank: 3, avatarUrl: "instructor1")
        ]
    }

    var leaderboardAllTimeCurrent: LeaderboardEntry {
        LeaderboardEntry(
            fullName: "You (Alex)",
            points: 1450,
            rank: 24,
            avatarUrl: "instructor2",
            isCurrentUser: true,
            weeklyChange: 3
        )
    }

    var topCurators: [LeaderboardEntry] {
        [
        LeaderboardEntry(fullName: "Elena Vance",   points: 14200, rank: 1, avatarUrl: "instructor2"),
        LeaderboardEntry(fullName: "Marcus Thorne", points: 12800, rank: 2, avatarUrl: "instructor1"),
        LeaderboardEntry(fullName: "Sana Kim",       points: 11900, rank: 3, avatarUrl: "instructor2")
        ]
    }

    // MARK: Badges & Milestones
    var rewardBadges: [RewardBadge] {
        [
        RewardBadge(title: "First Bloom",    iconName: "leaf.fill", colorHex: "2DBF8E"),
        RewardBadge(title: "Steady Growth",  iconName: "bolt.fill", colorHex: "1D9E75"),
        RewardBadge(title: "Master Mind",    iconName: "star.fill", colorHex: "FFD700"),
        RewardBadge(title: "Night Owl",      iconName: "moon.fill", colorHex: "5D5FEF")
        ]
    }

    var milestones: [Milestone] {
        [
        Milestone(title: "Publish 10 Case Studies", progress: 7,  total: 10, iconName: "doc.text.fill"),
        Milestone(title: "Help 50 Newbies",          progress: 22, total: 50, iconName: "person.2.fill")
        ]
    }

    // MARK: Wallet & Credits
    var creditPacks: [CreditPack] {
        [
        CreditPack(amount: 2500, bonusAmount: 500, price: "$49.99", isBestValue: true),
        CreditPack(amount: 1000, price: "$24.99")
        ]
    }

    // MARK: Skill Missions
    var skillMissions: [SkillMission] {
        [
        SkillMission(title: "Complete UI Basics",    rewardAmount: 150, status: .inProgress),
        SkillMission(title: "Peer Review Workshop",  rewardAmount: 300, status: .available)
        ]
    }
}
