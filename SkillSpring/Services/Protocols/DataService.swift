import Foundation
import Combine

/// Defines the shared asynchronous data operations used by SkillSpryng.
///
/// Implementations include Firestore-backed services and mock/test services.
@MainActor
protocol DataService: AnyObject {
    /// Fetches the current authenticated user's profile.
    func fetchCurrentUser() async -> User?

    /// Updates the user's wallet balance in persistent storage.
    func updateWalletBalance(_ newBalance: Int) async

    /// Creates a new session document for the user.
    func createSession(_ session: Session) async throws

    /// Records a wallet transaction entry.
    func createTransaction(_ transaction: CreditTransaction) async

    /// Creates a match request or acceptance record.
    func createMatch(_ match: MatchRequest) async throws

    /// Creates an in-app notification record.
    func createNotification(_ notification: AppNotification) async

    /// Creates a conversation thread for chat and links it to the current user.
    func createConversation(_ conversation: Conversation, currentUserId: String) async
}
