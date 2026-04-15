import Foundation
import Combine
import FirebaseFirestore

// MARK: - SessionsViewModel
// Drives MySessionsView. Sessions loaded via real-time Firestore snapshot listener.
// Architecture: MySessionsView → SessionsViewModel → FirebaseDataService → Firestore

@MainActor
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

    func refresh() async {
        isLoading = true
        sessions = await FirebaseDataService.shared.fetchSessions()
        isLoading = false
    }

    // MARK: - Session Status Update

    func completeSession(_ session: Session) {
        Task {
            await FirebaseDataService.shared.updateSessionStatus(session.id, status: .completed)
        }
    }

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
