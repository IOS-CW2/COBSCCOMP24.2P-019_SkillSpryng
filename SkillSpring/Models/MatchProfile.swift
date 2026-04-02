import Foundation

// MARK: - MatchProfile
// Represents a peer/mentor match shown on the Matches and Profile Detail screens.
struct MatchProfile: Identifiable {
    let id = UUID()
    let name: String
    let role: String
    let location: String
    let matchPercentage: Int
    let bio: String
    let canTeach: [String]
    let wantsToLearn: [String]
    let imageUrl: String
    let onlineStatus: Bool
    let city: String
}
