import SwiftUI

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    
    var body: some View {
        HStack(spacing: 16) {
            Text("\(entry.rank)")
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(entry.rank <= 3 ? AppTheme.Colors.primary : .gray)
                .frame(width: 20)
            
            Image(entry.avatarUrl)
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.fullName)
                    .font(AppTheme.Typography.subheadline)
                if let change = entry.weeklyChange {
                    HStack(spacing: 2) {
                        Image(systemName: "arrow.up")
                            .font(AppTheme.Typography.badge)
                        Text("\(change) this week")
                            .font(AppTheme.Typography.badge)
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                }
            }
            
            Spacer()
            
            Text("\(entry.points)")
                .font(AppTheme.Typography.subheadline)
            
            if entry.isCurrentUser {
                Circle()
                    .fill(AppTheme.Colors.primary)
                    .frame(width: 6, height: 6)
            }
        }
        .padding()
        .background(entry.isCurrentUser ? AppTheme.Colors.primary.opacity(0.1) : Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(entry.isCurrentUser ? AppTheme.Colors.primary : Color.clear, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Rank \(entry.rank). \(entry.fullName). " +
            "\(entry.points) points" +
            (entry.weeklyChange != nil ? ". Up \(entry.weeklyChange!) places this week" : "") +
            (entry.isCurrentUser ? ". This is you" : "")
        )
    }
}
