import Foundation
import Combine
import FirebaseFirestore

// MARK: - SessionsViewModel
// Drives MySessionsView. Sessions loaded via real-time Firestore snapshot listener.
// Architecture: MySessionsView → SessionsViewModel → FirebaseDataService → Firestore

@MainActor
/// Manages the user's session history and live updates from Firestore.
///
/// Uses a snapshot listener to keep the session list in sync and exposes
/// helper views for upcoming, completed, cancelled, and history sessions.
final class SessionsViewModel: ObservableObject {

    // MARK: - Published State
    @Published var sessions: [Session] = []
    @Published var isLoading: Bool = true

    // MARK: - Init

    init() {
        attachListener()
    }

    deinit {
        Task { @MainActor in
            FirebaseDataService.shared.stopListeningToSessions()
        }
    }

    // MARK: - Real-Time Listener

    private func attachListener() {
        FirebaseDataService.shared.listenToSessions { [weak self] liveSessions in
            guard let self else { return }
            self.sessions = liveSessions
            self.isLoading = false
        }
    }

    // MARK: - Manual Refresh (pull-to-refresh)

    /// Refreshes the session list from Firestore on demand.
    func refresh() async {
        isLoading = true
        sessions = await FirebaseDataService.shared.fetchSessions()
        isLoading = false
    }

    // MARK: - Session Status Update

    /// Marks a session as completed.
    /// `FirebaseDataService.updateSessionStatus` internally calls
    /// `awardSessionCompletionPoints` which atomically increments `walletBalance`
    /// via `FieldValue.increment`, writes a `CreditTransaction` (.sessionEarning),
    /// updates karma + leaderboard, and fires an in-app notification.
    /// This satisfies Proposal §2.1.7: "Completing sessions earns SKP atomically
    /// via Firestore's FieldValue.increment."
    /// Completes a session and triggers associated gamification updates.
    func completeSession(_ session: Session) {
        Task {
            await FirebaseDataService.shared.updateSessionStatus(session.id, status: .completed)
            HapticManager.success()
        }
    }

    /// Cancels a session by updating its Firestore status.
    func cancelSession(_ session: Session) {
        Task {
            await FirebaseDataService.shared.cancelSession(session.id)
        }
    }

    // MARK: - Derived Views

    var upcomingSessions: [Session] {
        sessions.filter { $0.status == .upcoming }
    }

    var completedSessions: [Session] {
        sessions.filter { $0.status == .completed }
    }

    var cancelledSessions: [Session] {
        sessions.filter { $0.status == .cancelled }
    }

    var todaySession: Session? {
        sessions.first { $0.status == .upcoming && $0.type == .online }
    }

    var tomorrowSession: Session? {
        upcomingSessions.dropFirst().first
    }

    var historySessions: [Session] {
        sessions.filter { $0.status == .completed || $0.status == .cancelled }
    }
}
