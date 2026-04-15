import SwiftUI

struct StreakCard: View {
    let streakCount: Int
    let subheadline: String
    
    var body: some View {
        HStack {
            Image(systemName: "flame.fill")
                .foregroundColor(.white)
                .padding(8)
                .background(Circle().fill(AppTheme.Colors.primary))
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(streakCount) Day Streak!")
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(.white)
                Text(subheadline)
                    .font(AppTheme.Typography.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white)
                .font(AppTheme.Typography.badge)
                .accessibilityHidden(true)
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.Gradients.streakCard)
        .cornerRadius(AppTheme.Radius.xl)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(streakCount) day streak. \(subheadline)")
        .accessibilityAddTraits(.isButton)
    }
}
