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
                    .font(AppTheme.Typography.title3)
                if let suffix = suffix {
                    Text(suffix)
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(.orange)
                }
            }
            Text(label)
                .font(AppTheme.Typography.badge)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label), \(value)\(suffix == "★" ? " stars" : (suffix != nil ? " \(suffix!)" : ""))")
    }
}
