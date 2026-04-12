import SwiftUI

struct ProfileStatRow: View {
    let sessions: Int
    let rating: Double
    let awards: Int
    
    var body: some View {
        HStack {
            StatItem(value: "\(sessions)", label: "SESSIONS")
            Divider().frame(height: 30)
            StatItem(value: String(format: "%.1f", rating), label: "RATING", suffix: "★")
            Divider().frame(height: 30)
            StatItem(value: "\(awards)", label: "AWARDS")
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }
}

private struct StatItem: View {
    let value: String
    let label: String
    var suffix: String? = nil
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                if let suffix = suffix {
                    Text(suffix)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.orange)
                }
            }
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label), \(value)\(suffix == "★" ? " stars" : (suffix != nil ? " \(suffix!)" : ""))")
    }
}
