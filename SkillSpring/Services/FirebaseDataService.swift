import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

// MARK: - FirebaseDataService
// Central async data service. ALL reads/writes go through here.
//
// ARCHITECTURE:  View → ViewModel → FirebaseDataService → Firestore
//
// Collections managed:
//   users/                        — user profiles
//   users/{uid}/sessions          — personal session history
//   users/{uid}/learningPath      — enrolled courses
//   users/{uid}/transactions      — SkillCredit financial log
//   users/{uid}/notifications     — in-app notification inbox
//   users/{uid}/gamification      — mastery + analytics docs
//   matches/                      — match requests between users
//   conversations/                — message threads
//   conversations/{id}/messages   — real-time message sub-collection
//   skills/                       — recommended skill listings
//   courses/                      — featured, popular, learning-path courses
//   events/                       — upcoming events
//   matchProfiles/                — public discovery profiles
//   leaderboard/                  — weekly rankings
//   rewardBadges/                 — badge definitions
//   milestones/                   — milestone definitions
//   skillMissions/                — mission definitions
//   creditPacks/                  — StoreKit credit pack definitions

@MainActor
final class FirebaseDataService {

    static let shared = FirebaseDataService()
    let db = Firestore.firestore()
    var uid: String? { Auth.auth().currentUser?.uid }

    // Active Firestore snapshot listeners (stored to cancel on deinit)
    private var sessionListener: ListenerRegistration?
    private var chatListeners: [String: ListenerRegistration] = [:]
    private var matchListener: ListenerRegistration?

    private init() {}

    // MARK: - ─────────────────────────────────────────────
    // MARK: CURRENT USER — CREATE / READ / UPDATE
    // ─────────────────────────────────────────────────────

    func fetchCurrentUser() async -> User? {
        guard let uid else { return nil }
        do {
            let snap = try await db.collection("users").document(uid).getDocument()
            if snap.exists, var user = try? snap.data(as: User.self) {
                user.id = snap.documentID
                return user
            }
        } catch {
            print("[FDS] fetchCurrentUser: \(error.localizedDescription)")
        }
        return nil
    }

    func saveUser(_ user: User) async throws {
        guard let uid else { throw NSError(domain: "FDS", code: -1) }
        var u = user; u.id = uid
        try db.collection("users").document(uid).setData(from: u, merge: true)
    }

    func updateWalletBalance(_ newBalance: Int) async {
        guard let uid else { return }
        try? await db.collection("users").document(uid)
            .updateData(["walletBalance": newBalance])
    }

    func updateUserLocation(lat: Double, lon: Double) async {
        guard let uid else { return }
        try? await db.collection("users").document(uid)
            .updateData(["latitude": lat, "longitude": lon, "lastActiveAt": FieldValue.serverTimestamp()])
    }

    // MARK: - ─────────────────────────────────────────────
    // MARK: SESSIONS — Full CRUD + Real-Time Listener
    // ─────────────────────────────────────────────────────

    /// One-time fetch of the current user's sessions.
    func fetchSessions() async -> [Session] {
        guard let uid else { return [] }
        do {
            let snap = try await db.collection("users").document(uid)
                .collection("sessions")
                .order(by: "createdAt", descending: true)
                .getDocuments()
            return snap.documents.compactMap { try? $0.data(as: Session.self) }
        } catch {
            print("[FDS] fetchSessions: \(error.localizedDescription)")
            return []
        }
    }

    /// Real-time Firestore listener — publishes updates to the provided closure.
    func listenToSessions(onChange: @escaping ([Session]) -> Void) {
        guard let uid else {
            onChange([])
            return
        }
        sessionListener?.remove()
        sessionListener = db.collection("users").document(uid)
            .collection("sessions")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snap, error in
                guard let snap, error == nil else {
                    if let error = error { print("[FDS] listenToSessions Error: \(error.localizedDescription)") }
                    onChange([])
                    return
                }
                let sessions = snap.documents.compactMap { try? $0.data(as: Session.self) }
                onChange(sessions)
            }
    }

    func stopListeningToSessions() {
        sessionListener?.remove()
        sessionListener = nil
    }

    /// CREATE — called when a booking is confirmed.
    func createSession(_ session: Session) async throws {
        guard let uid else { throw NSError(domain: "FDS", code: -1) }
        try db.collection("users").document(uid)
            .collection("sessions").document(session.id)
            .setData(from: session)
    }

    /// UPDATE session status (e.g. upcoming → completed).
    func updateSessionStatus(_ sessionId: String, status: SessionStatus) async {
        guard let uid else { return }
        try? await db.collection("users").document(uid)
            .collection("sessions").document(sessionId)
            .updateData([
                "status": status.rawValue,
                "completedAt": status == .completed ? FieldValue.serverTimestamp() : NSNull()
            ])

        // Award points if session completed
        if status == .completed {
            await awardSessionCompletionPoints(sessionId: sessionId)
        }
    }

    /// DELETE (cancel) a session.
    func cancelSession(_ sessionId: String) async {
        guard let uid else { return }
        // Soft delete — update status only
        try? await db.collection("users").document(uid)
            .collection("sessions").document(sessionId)
            .updateData(["status": SessionStatus.cancelled.rawValue])

        // Create cancellation notification
        await createNotification(AppNotification(
            type: .sessionCancelled,
            title: "Session Cancelled",
            body: "Your session has been cancelled.",
            referenceId: sessionId
        ))
    }

    // MARK: - ─────────────────────────────────────────────
    // MARK: MATCHES — Full CRUD + Real-Time Listener
    // ─────────────────────────────────────────────────────

    func createMatch(_ match: MatchRequest) async throws {
        try db.collection("matches").document(match.id).setData(from: match)

        // Notify the recipient
        await createNotification(AppNotification(
            type: .matchRequest,
            title: "New Match Request 🤝",
            body: "\(match.fromUserName) wants to swap skills with you.",
            referenceId: match.id
        ))
    }

    func listenToIncomingMatches(onChange: @escaping ([MatchRequest]) -> Void) {
        guard let uid else {
            onChange([])
            return
        }
        matchListener?.remove()
        matchListener = db.collection("matches")
            .whereField("toUserId", isEqualTo: uid)
            .whereField("status", isEqualTo: MatchRequestStatus.pending.rawValue)
            .addSnapshotListener { snap, error in
                guard let snap, error == nil else {
                    if let error = error { print("[FDS] listenToIncomingMatches Error: \(error.localizedDescription)") }
                    onChange([])
                    return
                }
                let matches = snap.documents.compactMap { try? $0.data(as: MatchRequest.self) }
                onChange(matches)
            }
    }

    func updateMatchStatus(_ matchId: String, status: MatchRequestStatus) async {
        try? await db.collection("matches").document(matchId)
            .updateData(["status": status.rawValue, "updatedAt": FieldValue.serverTimestamp()])
    }

    func fetchMatches() async -> [MatchRequest] {
        guard let uid else { return [] }
        do {
            let snap = try await db.collection("matches")
                .whereField("fromUserId", isEqualTo: uid)
                .getDocuments()
            return snap.documents.compactMap { try? $0.data(as: MatchRequest.self) }
        } catch { return [] }
    }

    // MARK: - ─────────────────────────────────────────────
    // MARK: CREDIT TRANSACTIONS — CREATE / READ
    // ─────────────────────────────────────────────────────

    func createTransaction(_ transaction: CreditTransaction) async {
        guard let uid else { return }
        try? db.collection("users").document(uid)
            .collection("transactions").document(transaction.id)
            .setData(from: transaction)
    }

    func fetchTransactions() async -> [CreditTransaction] {
        guard let uid else { return [] }
        do {
            let snap = try await db.collection("users").document(uid)
                .collection("transactions")
                .order(by: "createdAt", descending: true)
                .limit(to: 50)
                .getDocuments()
            return snap.documents.compactMap { try? $0.data(as: CreditTransaction.self) }
        } catch { return [] }
    }

    // MARK: - ─────────────────────────────────────────────
    // MARK: MESSAGES — CREATE + Real-Time Listener
    // ─────────────────────────────────────────────────────

    func listenToMessages(conversationId: String, onChange: @escaping ([ChatMessage]) -> Void) {
        chatListeners[conversationId]?.remove()
        chatListeners[conversationId] = db
            .collection("conversations").document(conversationId)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { snap, error in
                guard let snap, error == nil else {
                    if let error = error { print("[FDS] listenToMessages Error: \(error.localizedDescription)") }
                    onChange([])
                    return
                }
                let messages = snap.documents.compactMap { try? $0.data(as: ChatMessage.self) }
                onChange(messages)
            }
    }

    func stopListeningToMessages(conversationId: String) {
        chatListeners[conversationId]?.remove()
        chatListeners.removeValue(forKey: conversationId)
    }

    func sendMessage(_ message: ChatMessage, to conversationId: String) async {
        guard let uid else { return }
        // Write message to sub-collection
        try? db.collection("conversations").document(conversationId)
            .collection("messages").document(message.id)
            .setData(from: message)

        // Update conversation metadata
        try? await db.collection("conversations").document(conversationId).updateData([
            "lastMessage": message.text ?? "",
            "lastMessageTime": FieldValue.serverTimestamp(),
            "senderId": uid
        ])
    }

    func markMessageRead(_ messageId: String, conversationId: String) async {
        try? await db.collection("conversations").document(conversationId)
            .collection("messages").document(messageId)
            .updateData(["isRead": true])
    }

    func deleteMessage(_ messageId: String, conversationId: String) async {
        // Soft delete
        try? await db.collection("conversations").document(conversationId)
            .collection("messages").document(messageId)
            .updateData(["isDeleted": true, "text": "This message was deleted."])
    }

    func fetchConversations() async -> [Conversation] {
        guard let uid else { return MockDataProvider.shared.mockConversations }
        do {
            let snap = try await db.collection("conversations")
                .whereField("participantIds", arrayContains: uid)
                .order(by: "lastMessageTime", descending: true)
                .getDocuments()
            if snap.documents.isEmpty {
                await seedConversations(uid: uid)
                return MockDataProvider.shared.mockConversations
            }
            return snap.documents.compactMap { try? $0.data(as: Conversation.self) }
        } catch { return MockDataProvider.shared.mockConversations }
    }

    private func seedConversations(uid: String) async {
        let batch = db.batch()
        for conv in MockDataProvider.shared.mockConversations {
            let ref = db.collection("conversations").document(conv.id)
            if var data = try? Firestore.Encoder().encode(conv) {
                data["participantIds"] = [uid, conv.participant.id ?? UUID().uuidString]
                batch.setData(data, forDocument: ref)
            }
        }
        try? await batch.commit()
    }

    // MARK: - ─────────────────────────────────────────────
    // MARK: PROFILES — READ
    // ─────────────────────────────────────────────────────

    func fetchProfiles() async -> [MatchProfile] {
        do {
            let snap = try await db.collection("matchProfiles").getDocuments()
            if snap.documents.isEmpty {
                await seedProfiles()
                return MockDataProvider.shared.allProfiles
            }
            return snap.documents.compactMap { try? $0.data(as: MatchProfile.self) }
        } catch { return MockDataProvider.shared.allProfiles }
    }

    private func seedProfiles() async {
        let batch = db.batch()
        for profile in MockDataProvider.shared.allProfiles {
            let ref = db.collection("matchProfiles").document(profile.id)
            if let data = try? Firestore.Encoder().encode(profile) {
                batch.setData(data, forDocument: ref)
            }
        }
        try? await batch.commit()
    }

    // MARK: - ─────────────────────────────────────────────
    // MARK: SKILLS / COURSES / EVENTS — READ
    // ─────────────────────────────────────────────────────

    func fetchRecommendedSkills() async -> [RecommendedSkill] {
        do {
            let snap = try await db.collection("skills")
                .whereField("isRecommended", isEqualTo: true).getDocuments()
            if snap.documents.isEmpty { await seedSkills(); return MockDataProvider.shared.recommendedSkills }
            return snap.documents.compactMap { try? $0.data(as: RecommendedSkill.self) }
        } catch { return MockDataProvider.shared.recommendedSkills }
    }

    func fetchFeaturedCourses() async -> [Course] {
        do {
            let snap = try await db.collection("courses")
                .whereField("isFeatured", isEqualTo: true).getDocuments()
            if snap.documents.isEmpty { await seedCourses(); return MockDataProvider.shared.featuredCourses }
            return snap.documents.compactMap { try? $0.data(as: Course.self) }
        } catch { return MockDataProvider.shared.featuredCourses }
    }

    func fetchPopularCourses() async -> [Course] {
        do {
            let snap = try await db.collection("courses")
                .whereField("isPopular", isEqualTo: true).getDocuments()
            if snap.documents.isEmpty { return MockDataProvider.shared.popularCourses }
            return snap.documents.compactMap { try? $0.data(as: Course.self) }
        } catch { return MockDataProvider.shared.popularCourses }
    }

    func fetchLearningPath() async -> [Course] {
        guard let uid else { return MockDataProvider.shared.learningPath }
        do {
            let snap = try await db.collection("users").document(uid)
                .collection("learningPath").getDocuments()
            if snap.documents.isEmpty { return MockDataProvider.shared.learningPath }
            return snap.documents.compactMap { try? $0.data(as: Course.self) }
        } catch { return MockDataProvider.shared.learningPath }
    }

    /// CREATE / UPDATE — enrols the user in a course and persists it to Firestore.
    /// Safe to call on re-enrolment; uses merge so existing progress is not overwritten.
    func saveLearningProgress(course: Course) async throws {
        guard let uid else { throw NSError(domain: "FDS", code: -1) }
        try db.collection("users").document(uid)
            .collection("learningPath").document(course.id)
            .setData(from: course, merge: true)
    }

    /// UPDATE — writes only the `progress` field so partial progress is persisted
    /// without overwriting other course metadata.
    func updateCourseProgress(_ courseId: String, progress: Double) async {
        guard let uid else { return }
        let clamped = min(max(progress, 0), 1)   // clamp to [0, 1]
        try? await db.collection("users").document(uid)
            .collection("learningPath").document(courseId)
            .updateData(["progress": clamped, "updatedAt": FieldValue.serverTimestamp()])
    }

    func fetchUpcomingEvents() async -> [Event] {
        do {
            let snap = try await db.collection("events").getDocuments()
            if snap.documents.isEmpty { await seedEvents(); return MockDataProvider.shared.upcomingEvents }
            return snap.documents.compactMap { try? $0.data(as: Event.self) }
        } catch { return MockDataProvider.shared.upcomingEvents }
    }

    private func seedSkills() async {
        let batch = db.batch()
        for skill in MockDataProvider.shared.recommendedSkills {
            let ref = db.collection("skills").document(skill.id)
            var data = (try? Firestore.Encoder().encode(skill)) ?? [:]
            data["isRecommended"] = true
            batch.setData(data, forDocument: ref)
        }
        try? await batch.commit()
    }

    private func seedCourses() async {
        let batch = db.batch()
        for course in MockDataProvider.shared.featuredCourses {
            var data = (try? Firestore.Encoder().encode(course)) ?? [:]
            data["isFeatured"] = true; data["isPopular"] = false
            batch.setData(data, forDocument: db.collection("courses").document(course.id))
        }
        for course in MockDataProvider.shared.popularCourses {
            var data = (try? Firestore.Encoder().encode(course)) ?? [:]
            data["isFeatured"] = false; data["isPopular"] = true
            batch.setData(data, forDocument: db.collection("courses").document(course.id))
        }
        try? await batch.commit()
    }

    private func seedEvents() async {
        let batch = db.batch()
        for event in MockDataProvider.shared.upcomingEvents {
            if let data = try? Firestore.Encoder().encode(event) {
                batch.setData(data, forDocument: db.collection("events").document(event.id))
            }
        }
        try? await batch.commit()
    }

    // MARK: - ─────────────────────────────────────────────
    // MARK: LEADERBOARD + GAMIFICATION — READ / UPDATE
    // ─────────────────────────────────────────────────────

    func fetchLeaderboard() async -> [LeaderboardEntry] {
        do {
            let snap = try await db.collection("leaderboard")
                .order(by: "points", descending: true).limit(to: 20).getDocuments()
            if snap.documents.isEmpty { await seedLeaderboard(); return MockDataProvider.shared.leaderboardWeekly }
            return snap.documents.compactMap { try? $0.data(as: LeaderboardEntry.self) }
        } catch { return MockDataProvider.shared.leaderboardWeekly }
    }

    private func seedLeaderboard() async {
        let batch = db.batch()
        for entry in MockDataProvider.shared.leaderboardWeekly {
            if let data = try? Firestore.Encoder().encode(entry) {
                batch.setData(data, forDocument: db.collection("leaderboard").document(entry.id))
            }
        }
        try? await batch.commit()
    }

    func fetchRewardBadges() async -> [RewardBadge] {
        do {
            let snap = try await db.collection("rewardBadges").getDocuments()
            if snap.documents.isEmpty { return MockDataProvider.shared.rewardBadges }
            return snap.documents.compactMap { try? $0.data(as: RewardBadge.self) }
        } catch { return MockDataProvider.shared.rewardBadges }
    }

    func fetchMilestones() async -> [Milestone] {
        do {
            let snap = try await db.collection("milestones").getDocuments()
            if snap.documents.isEmpty { return MockDataProvider.shared.milestones }
            return snap.documents.compactMap { try? $0.data(as: Milestone.self) }
        } catch { return MockDataProvider.shared.milestones }
    }

    func fetchSkillMissions() async -> [SkillMission] {
        do {
            let snap = try await db.collection("skillMissions").getDocuments()
            if snap.documents.isEmpty { return MockDataProvider.shared.skillMissions }
            return snap.documents.compactMap { try? $0.data(as: SkillMission.self) }
        } catch { return MockDataProvider.shared.skillMissions }
    }

    func fetchCreditPacks() async -> [CreditPack] {
        do {
            let snap = try await db.collection("creditPacks").getDocuments()
            if snap.documents.isEmpty { return MockDataProvider.shared.creditPacks }
            return snap.documents.compactMap { try? $0.data(as: CreditPack.self) }
        } catch { return MockDataProvider.shared.creditPacks }
    }

    func fetchMasteryData() async -> MasteryPoints {
        guard let uid else { return MockDataProvider.shared.masteryData }
        do {
            let snap = try await db.collection("users").document(uid)
                .collection("gamification").document("mastery").getDocument()
            if snap.exists, let data = try? snap.data(as: MasteryPoints.self) { return data }
        } catch {}
        return MockDataProvider.shared.masteryData
    }

    func fetchAnalyticsData() async -> AnalyticsData {
        guard let uid else { return MockDataProvider.shared.analyticsData }
        do {
            let snap = try await db.collection("users").document(uid)
                .collection("gamification").document("analytics").getDocument()
            if snap.exists, let data = try? snap.data(as: AnalyticsData.self) { return data }
        } catch {}
        return MockDataProvider.shared.analyticsData
    }

    // MARK: - ─────────────────────────────────────────────
    // MARK: GAMIFICATION WRITE-BACK
    // Award points when a session is completed.
    // ─────────────────────────────────────────────────────

    private let sessionCompletionPoints = 150
    private let teachingBonusPoints    = 50

    func awardSessionCompletionPoints(sessionId: String) async {
        guard let uid else { return }
        let gamRef = db.collection("users").document(uid)
            .collection("gamification").document("mastery")

        // Increment mastery total
        try? await gamRef.updateData([
            "total": FieldValue.increment(Int64(sessionCompletionPoints))
        ])

        // Increment karma on user doc
        try? await db.collection("users").document(uid)
            .updateData([
                "karmaPoints":   FieldValue.increment(Int64(sessionCompletionPoints)),
                "sessionsCount": FieldValue.increment(Int64(1))
            ])

        // Update leaderboard (upsert)
        if let user = await fetchCurrentUser() {
            let leaderboardRef = db.collection("leaderboard").document(uid)
            try? await leaderboardRef.setData([
                "id":           uid,
                "fullName":     user.fullName,
                "avatarUrl":    user.profileImageURL,
                "points":       FieldValue.increment(Int64(sessionCompletionPoints)),
                "isCurrentUser": true
            ], merge: true)
        }

        // Write reward notification
        await createNotification(AppNotification(
            type: .rewardEarned,
            title: "Session Complete! 🎉",
            body: "You earned \(sessionCompletionPoints) karma points.",
            referenceId: sessionId
        ))

        // Write transaction record
        if let user = await fetchCurrentUser() {
            let tx = CreditTransaction(
                amount: sessionCompletionPoints,
                type: .sessionEarning,
                description: "Session completion reward",
                balanceAfter: user.walletBalance + sessionCompletionPoints,
                referenceId: sessionId
            )
            await createTransaction(tx)
            await updateWalletBalance(user.walletBalance + sessionCompletionPoints)
        }
    }

    // MARK: - ─────────────────────────────────────────────
    // MARK: NOTIFICATIONS — CREATE / READ
    // ─────────────────────────────────────────────────────

    func createNotification(_ notification: AppNotification) async {
        guard let uid else { return }
        try? db.collection("users").document(uid)
            .collection("notifications").document(notification.id)
            .setData(from: notification)
    }

    func fetchNotifications() async -> [AppNotification] {
        guard let uid else { return [] }
        do {
            let snap = try await db.collection("users").document(uid)
                .collection("notifications")
                .order(by: "createdAt", descending: true)
                .limit(to: 30)
                .getDocuments()
            return snap.documents.compactMap { try? $0.data(as: AppNotification.self) }
        } catch { return [] }
    }

    func markNotificationRead(_ notifId: String) async {
        guard let uid else { return }
        try? await db.collection("users").document(uid)
            .collection("notifications").document(notifId)
            .updateData(["isRead": true])
    }

    // MARK: - ─────────────────────────────────────────────
    // MARK: DEBUG
    // ─────────────────────────────────────────────────────

    func debugPrintAll() async {
        let collections = ["users", "skills", "courses", "events",
                           "conversations", "matchProfiles", "leaderboard",
                           "matches", "rewardBadges", "milestones", "skillMissions"]
        print("\n========== 🔥 FIRESTORE DATA REPORT ==========")
        for name in collections {
            do {
                let snap = try await db.collection(name).getDocuments()
                print("[🔥 DB] \(name): \(snap.documents.count) document(s)")
                for doc in snap.documents.prefix(2) {
                    print("       ↳ \(doc.documentID): \(doc.data().keys.sorted().joined(separator: ", "))")
                }
            } catch {
                print("[🔥 DB] \(name): error - \(error.localizedDescription)")
            }
        }
        if let uid {
            for col in ["sessions", "transactions", "notifications"] {
                do {
                    let snap = try await db.collection("users").document(uid)
                        .collection(col).getDocuments()
                    print("[🔥 DB] users/\(uid)/\(col): \(snap.documents.count) document(s)")
                } catch {
                    print("[🔥 DB] \(col): error - \(error.localizedDescription)")
                }
            }
        }
        print("==============================================\n")
    }
}
