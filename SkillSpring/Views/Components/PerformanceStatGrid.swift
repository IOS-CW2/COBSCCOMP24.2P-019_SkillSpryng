// MARK: - PerformanceStatGrid
// Stats grid visualizing session performance metrics.
import SwiftUI

struct PerformanceStatGrid: View {
    let duration: String
    let credits: Int
    let rating: Double
    
    var body: some View {
        HStack(spacing: 12) {
            PerformanceStatCard(title: "Duration", value: duration, icon: "timer")
            PerformanceStatCard(title: "Credits", value: "\(credits)", icon: "leaf.fill")
            PerformanceStatCard(title: "Rating", value: String(format: "%.1f", rating), icon: "star.fill")
        }
    }
}

struct PerformanceStatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.primary.opacity(0.1))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(AppTheme.Typography.callout)
                    .foregroundColor(AppTheme.Colors.primary)
            }
            .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.Typography.badge)
                    .foregroundColor(.gray)
                Text(value)
                    .font(AppTheme.Typography.subheadline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(value)")
    }
}
