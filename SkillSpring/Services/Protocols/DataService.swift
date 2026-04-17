import Foundation
import Combine

@MainActor
protocol DataService: AnyObject {
    func fetchCurrentUser() async -> User?
    func updateWalletBalance(_ newBalance: Int) async
    func createSession(_ session: Session) async throws
    func createTransaction(_ transaction: CreditTransaction) async
    func createMatch(_ match: MatchRequest) async throws
    func createNotification(_ notification: AppNotification) async
}
