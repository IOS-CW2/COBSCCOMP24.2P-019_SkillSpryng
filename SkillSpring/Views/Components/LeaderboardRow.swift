import SwiftUI

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    
    var body: some View {
        HStack(spacing: 16) {
            Text("\(entry.rank)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(entry.rank <= 3 ? AppTheme.Colors.primary : .gray)
                .frame(width: 20)
            
            Image(entry.avatarUrl)
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.fullName)
                    .font(.system(size: 14, weight: .bold))
                if let change = entry.weeklyChange {
                    HStack(spacing: 2) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 8, weight: .bold))
                        Text("\(change) this week")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                }
            }
            
            Spacer()
            
            Text("\(entry.points)")
                .font(.system(size: 14, weight: .bold))
            
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
    }
}
