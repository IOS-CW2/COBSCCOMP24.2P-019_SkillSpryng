import Foundation
import FirebaseFirestore
import FirebaseAuth

// MARK: - DataSeeder
// One-shot utility that writes ALL MockDataProvider data to Firestore
// as properly structured collections. Safe to call multiple times —
// it checks if data already exists before writing.
//
// Collections created:
//   matchProfiles/     — all user profiles for discover & matching
//   skills/            — recommended skills for discover feed
//   courses/           — featured, popular & learning-path courses
//   events/            — upcoming events
//   leaderboard/       — weekly leaderboard entries
//   conversations/     — mock conversations (linked to authenticated user)
//   users/{uid}/sessions        — this user's sessions
//   users/{uid}/learningPath    — this user's enrolled courses

@MainActor
final class DataSeeder: DataSeedingService {

    static let shared = DataSeeder()
    private let db = Firestore.firestore()
    private var uid: String? { FirebaseManager.currentUID ?? "DEMO_TEST_USER_ID" }
    private let mock = MockDataProvider.shared

    private init() {}

    // MARK: - Seed All

    /// Seeds every collection. Call once after login.
    /// Skips collections that already have documents.
    func seedAll() async {
        print("\n🌱 ========= DataSeeder: Starting full seed =========")
        await seedProfiles()
        await seedSkills()
        await seedCourses()
        await seedEvents()
        await seedLeaderboard()
        await seedConversations()
        await seedUserSessions()
        await seedUserProfile()
        await seedGamification()
        await seedMatches()           // ← matches/ collection
        await seedLearningPath()      // ← users/{uid}/learningPath
        await seedNotifications()     // ← users/{uid}/notifications
        await seedTransactions()      // ← users/{uid}/transactions
        print("🌱 ====================================================\n")
    }

    // MARK: - matchProfiles/

    private func seedProfiles() async {
        let ref = db.collection("matchProfiles")
        guard await isEmpty(ref) else {
            print("🌱 matchProfiles: already seeded — skipping")
            return
        }
        let batch = db.batch()
        for profile in mock.allProfiles {
            if let data = try? Firestore.Encoder().encode(profile) {
                batch.setData(data, forDocument: ref.document(profile.id))
            }
        }
        do {
            try await batch.commit()
            print("🌱 matchProfiles: ✅ seeded \(mock.allProfiles.count) profiles")
        } catch {
            print("🌱 matchProfiles: ❌ \(error.localizedDescription)")
        }
    }

    // MARK: - skills/

    private func seedSkills() async {
        let ref = db.collection("skills")
        guard await isEmpty(ref) else {
            print("🌱 skills: already seeded — skipping")
            return
        }
        let batch = db.batch()
        for skill in mock.recommendedSkills {
            if var data = try? Firestore.Encoder().encode(skill) {
                data["isRecommended"] = true
                batch.setData(data, forDocument: ref.document(skill.id))
            }
        }
        do {
            try await batch.commit()
            print("🌱 skills: ✅ seeded \(mock.recommendedSkills.count) skills")
        } catch {
            print("🌱 skills: ❌ \(error.localizedDescription)")
        }
    }

    // MARK: - courses/

    private func seedCourses() async {
        let ref = db.collection("courses")
        guard await isEmpty(ref) else {
            print("🌱 courses: already seeded — skipping")
            return
        }
        let batch = db.batch()

        for course in mock.featuredCourses {
            if var data = try? Firestore.Encoder().encode(course) {
                data["isFeatured"] = true
                data["isPopular"]  = false
                data["isLearningPath"] = false
                batch.setData(data, forDocument: ref.document(course.id))
            }
        }
        for course in mock.popularCourses {
            if var data = try? Firestore.Encoder().encode(course) {
                data["isFeatured"] = false
                data["isPopular"]  = true
                data["isLearningPath"] = false
                batch.setData(data, forDocument: ref.document(course.id))
            }
        }
        for course in mock.learningPath {
            if var data = try? Firestore.Encoder().encode(course) {
                data["isFeatured"] = false
                data["isPopular"]  = false
                data["isLearningPath"] = true
                batch.setData(data, forDocument: ref.document(course.id))
            }
        }
        let total = mock.featuredCourses.count + mock.popularCourses.count + mock.learningPath.count
        do {
            try await batch.commit()
            print("🌱 courses: ✅ seeded \(total) courses")
        } catch {
            print("🌱 courses: ❌ \(error.localizedDescription)")
        }
    }

    // MARK: - events/

    private func seedEvents() async {
        let ref = db.collection("events")
        guard await isEmpty(ref) else {
            print("🌱 events: already seeded — skipping")
            return
        }
        let batch = db.batch()

        // Hero event
        let hero = mock.happeningSoonEvent
        if var data = try? Firestore.Encoder().encode(hero) {
            data["isHero"] = true
            batch.setData(data, forDocument: ref.document(hero.id))
        }
        // Upcoming events
        for event in mock.upcomingEvents {
            if var data = try? Firestore.Encoder().encode(event) {
                data["isHero"] = false
                batch.setData(data, forDocument: ref.document(event.id))
            }
        }
        let total = 1 + mock.upcomingEvents.count
        do {
            try await batch.commit()
            print("🌱 events: ✅ seeded \(total) events")
        } catch {
            print("🌱 events: ❌ \(error.localizedDescription)")
        }
    }

    // MARK: - leaderboard/

    private func seedLeaderboard() async {
        let ref = db.collection("leaderboard")
        guard await isEmpty(ref) else {
            print("🌱 leaderboard: already seeded — skipping")
            return
        }
        let batch = db.batch()

        for entry in mock.leaderboardWeekly {
            if var data = try? Firestore.Encoder().encode(entry) {
                data["period"] = "weekly"
                batch.setData(data, forDocument: ref.document(entry.id))
            }
        }
        for entry in mock.topCurators {
            if var data = try? Firestore.Encoder().encode(entry) {
                data["period"] = "curators"
                batch.setData(data, forDocument: ref.document(entry.id))
            }
        }
        let total = mock.leaderboardWeekly.count + mock.topCurators.count
        do {
            try await batch.commit()
            print("🌱 leaderboard: ✅ seeded \(total) entries")
        } catch {
            print("🌱 leaderboard: ❌ \(error.localizedDescription)")
        }
    }

    // MARK: - conversations/

    private func seedConversations() async {
        guard let uid else {
            print("🌱 conversations: ⚠️ skipped — no authenticated user")
            return
        }
        let ref = db.collection("conversations")
        guard await isEmpty(ref) else {
            print("🌱 conversations: already seeded — skipping")
            return
        }
        let batch = db.batch()
        for conv in mock.mockConversations {
            if var data = try? Firestore.Encoder().encode(conv) {
                data["participantIds"] = [uid, conv.participant.id ?? UUID().uuidString]
                batch.setData(data, forDocument: ref.document(conv.id))

                // Seed messages as sub-collection
                for message in conv.messages {
                    let msgRef = ref.document(conv.id).collection("messages").document(message.id)
                    if let msgData = try? Firestore.Encoder().encode(message) {
                        batch.setData(msgData, forDocument: msgRef)
                    }
                }
            }
        }
        do {
            try await batch.commit()
            print("🌱 conversations: ✅ seeded \(mock.mockConversations.count) conversations")
        } catch {
            print("🌱 conversations: ❌ \(error.localizedDescription)")
        }
    }

    // MARK: - users/{uid}/sessions

    private func seedUserSessions() async {
        guard let uid else {
            print("🌱 sessions: ⚠️ skipped — no authenticated user")
            return
        }
        let ref = db.collection("users").document(uid).collection("sessions")
        guard await isEmpty(ref) else {
            print("🌱 sessions: already seeded — skipping")
            return
        }
        let batch = db.batch()
        for session in mock.mockSessions {
            if let data = try? Firestore.Encoder().encode(session) {
                batch.setData(data, forDocument: ref.document(session.id))
            }
        }
        do {
            try await batch.commit()
            print("🌱 sessions: ✅ seeded \(mock.mockSessions.count) sessions")
        } catch {
            print("🌱 sessions: ❌ \(error.localizedDescription)")
        }
    }

    // MARK: - users/{uid} (current user profile)

    private func seedUserProfile() async {
        guard let uid else {
            print("🌱 userProfile: ⚠️ skipped — no authenticated user")
            return
        }
        let ref = db.collection("users").document(uid)
        do {
            let snap = try await ref.getDocument()
            if snap.exists {
                print("🌱 userProfile: already exists — skipping")
                return
            }
            var user = mock.currentUser
            user.id = uid
            if let data = try? Firestore.Encoder().encode(user) {
                try await ref.setData(data)
                print("🌱 userProfile: ✅ seeded current user profile")
            }
        } catch {
            print("🌱 userProfile: ❌ \(error.localizedDescription)")
        }
    }

    // MARK: - Helper

    private func isEmpty(_ ref: CollectionReference) async -> Bool {
        do {
            let snap = try await ref.limit(to: 1).getDocuments()
            return snap.documents.isEmpty
        } catch {
            return true
        }
    }

    // MARK: - Gamification & Analytics Seeding

    func seedGamification() async {
        print("🌱 Seeding Gamification & Analytics Data...")
        await seedPublicGamification()
        await seedUserGamification()
    }

/// Seeds public gamification.
    private func seedPublicGamification() async {
        let collections = [
            ("rewardBadges", mock.rewardBadges.map { try? Firestore.Encoder().encode($0) }),
            ("milestones", mock.milestones.map { try? Firestore.Encoder().encode($0) }),
            ("skillMissions", mock.skillMissions.map { try? Firestore.Encoder().encode($0) }),
            ("creditPacks", mock.creditPacks.map { try? Firestore.Encoder().encode($0) })
        ]
        
        let batch = db.batch()
        for (colName, items) in collections {
            let ref = db.collection(colName)
            if await isEmpty(ref) {
                for item in items.compactMap({ $0 }) {
                    let docRef = ref.document()
                    batch.setData(item, forDocument: docRef)
                }
            }
        }
        try? await batch.commit()
    }

/// Seeds user gamification.
    private func seedUserGamification() async {
        guard let uid else { return }
        let userRef = db.collection("users").document(uid).collection("gamification")
        
        // Seed Mastery
        let masteryRef = userRef.document("mastery")
        let mSnap = try? await masteryRef.getDocument()
        if mSnap?.exists == false {
            if let data = try? Firestore.Encoder().encode(mock.masteryData) {
                try? await masteryRef.setData(data)
            }
        }
        
        // Seed Analytics
        let analyticsRef = userRef.document("analytics")
        let aSnap = try? await analyticsRef.getDocument()
        if aSnap?.exists == false {
            if let data = try? Firestore.Encoder().encode(mock.analyticsData) {
                try? await analyticsRef.setData(data)
            }
        }
    }


    // MARK: - matches/
    // Seeds the `matches` root collection with realistic pending/accepted requests
    // so the MyMatchesInboxView is populated without needing real user interactions.

    private func seedMatches() async {
        let ref = db.collection("matches")
        guard await isEmpty(ref) else {
            print("🌱 matches: already seeded — skipping")
            return
        }
        guard let uid else {
            print("🌱 matches: ⚠️ skipped — no authenticated user")
            return
        }
        let batch = db.batch()
        // Build one match per profile using the current user as the sender.
        for profile in mock.allProfiles.prefix(4) {
            let toId = profile.id
            let match = MatchRequest(
                fromUserId: uid,
                toUserId: toId,
                fromUserName: mock.currentUser.fullName,
                toUserName: profile.fullName,
                skillOffered: mock.currentUser.skillsToTeach.first ?? "UI Design",
                skillWanted: profile.skillsToLearn.first ?? "Pottery",
                status: .pending,
                message: "Hey \(profile.fullName.split(separator: " ").first ?? "there")! I'd love to swap skills with you."
            )
            if let data = try? Firestore.Encoder().encode(match) {
                batch.setData(data, forDocument: ref.document(match.id))
            }
        }
        do {
            try await batch.commit()
            print("🌱 matches: ✅ seeded \(min(mock.allProfiles.count, 4)) match requests")
        } catch {
            print("🌱 matches: ❌ \(error.localizedDescription)")
        }
    }

    // MARK: - users/{uid}/learningPath
    // Seeds the learningPath sub-collection so CoursesView has data
    // without the user needing to manually enrol in a course first.

    private func seedLearningPath() async {
        guard let uid else {
            print("🌱 learningPath: ⚠️ skipped — no authenticated user")
            return
        }
        let ref = db.collection("users").document(uid).collection("learningPath")
        guard await isEmpty(ref) else {
            print("🌱 learningPath: already seeded — skipping")
            return
        }
        let batch = db.batch()
        for course in mock.learningPath {
            if let data = try? Firestore.Encoder().encode(course) {
                batch.setData(data, forDocument: ref.document(course.id))
            }
        }
        do {
            try await batch.commit()
            print("🌱 learningPath: ✅ seeded \(mock.learningPath.count) courses")
        } catch {
            print("🌱 learningPath: ❌ \(error.localizedDescription)")
        }
    }

    // MARK: - users/{uid}/notifications
    // Seeds a welcome notification and a session-reminder so the
    // Notifications inbox is not empty on first launch.

    private func seedNotifications() async {
        guard let uid else {
            print("🌱 notifications: ⚠️ skipped — no authenticated user")
            return
        }
        let ref = db.collection("users").document(uid).collection("notifications")
        guard await isEmpty(ref) else {
            print("🌱 notifications: already seeded — skipping")
            return
        }
        let notifications = [
            AppNotification(
                type: .systemAlert,
                title: "Welcome to SkillSpryng! 🎉",
                body: "You have been given 500 SKP starter credits. Find a mentor and book your first session!",
                referenceId: nil
            ),
            AppNotification(
                type: .matchRequest,
                title: "New Match Request 🤝",
                body: "Elena Rodriguez wants to swap UI Design for TypeScript skills with you.",
                referenceId: nil
            ),
            AppNotification(
                type: .sessionReminder,
                title: "Session Reminder ⏰",
                body: "Your Advanced Creative Strategy session starts in 2 hours.",
                referenceId: nil
            ),
            AppNotification(
                type: .rewardEarned,
                title: "Badge Unlocked! 🏅",
                body: "You earned the First Bloom badge for completing your profile.",
                referenceId: nil
            )
        ]
        let batch = db.batch()
        for notif in notifications {
            if let data = try? Firestore.Encoder().encode(notif) {
                batch.setData(data, forDocument: ref.document(notif.id))
            }
        }
        do {
            try await batch.commit()
            print("🌱 notifications: ✅ seeded \(notifications.count) notifications")
        } catch {
            print("🌱 notifications: ❌ \(error.localizedDescription)")
        }
    }

    // MARK: - users/{uid}/transactions
    // Seeds 3 demo transactions so the Wallet History screen is not empty
    // and so Firestore shows the sub-collection exists.

    private func seedTransactions() async {
        guard let uid else {
            print("🌱 transactions: ⚠️ skipped — no authenticated user")
            return
        }
        let ref = db.collection("users").document(uid).collection("transactions")
        guard await isEmpty(ref) else {
            print("🌱 transactions: already seeded — skipping")
            return
        }
        let transactions = [
            CreditTransaction(
                amount: 500,
                type: .rewardBonus,
                description: "Welcome bonus — starter SKP credits",
                balanceAfter: 500,
                referenceId: nil
            ),
            CreditTransaction(
                amount: -150,
                type: .sessionPayment,
                description: "Session: Advanced Creative Strategy (90 min)",
                balanceAfter: 350,
                referenceId: nil
            ),
            CreditTransaction(
                amount: 150,
                type: .sessionEarning,
                description: "Session completion reward — Advanced Brand Identity",
                balanceAfter: 500,
                referenceId: nil
            )
        ]
        let batch = db.batch()
        for tx in transactions {
            if let data = try? Firestore.Encoder().encode(tx) {
                batch.setData(data, forDocument: ref.document(tx.id))
            }
        }
        do {
            try await batch.commit()
            print("🌱 transactions: ✅ seeded \(transactions.count) transactions")
        } catch {
            print("🌱 transactions: ❌ \(error.localizedDescription)")
        }
    }

}
