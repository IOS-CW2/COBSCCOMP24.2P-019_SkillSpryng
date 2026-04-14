import SwiftUI

struct BadgeIcon: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(AppTheme.Typography.title3)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(AppTheme.Typography.badge)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .frame(width: 60)
        }
    }
}

#Preview {
    HStack {
        BadgeIcon(title: "Top 1%", icon: "crown.fill", color: .yellow)
        BadgeIcon(title: "30 Day Streak", icon: "flame.fill", color: .orange)
    }
    .padding()
}
