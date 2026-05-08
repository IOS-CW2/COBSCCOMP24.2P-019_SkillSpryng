import Foundation

/// Protocol for a service that seeds development or mock data.
///
/// Used to populate Firestore with sample users, sessions, courses, events,
/// and leaderboard data during app startup or testing.
protocol DataSeedingService: Sendable {
    /// Seed all required mock data sets asynchronously.
    func seedAll() async
}
