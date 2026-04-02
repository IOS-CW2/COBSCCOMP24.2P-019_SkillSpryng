import SwiftUI

struct MatchesCard: View {
    let profile: MatchProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                // Profile Image with Online Status
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                        )
                    
                    if profile.onlineStatus {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 14, height: 14)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(profile.name)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        // Match Percentage Badge
                        HStack(spacing: 4) {
                            Text("\(profile.matchPercentage)%")
                                .font(AppTheme.Typography.badge)
                                .fontWeight(.bold)
                            Image(systemName: "bolt.fill")
                                .font(AppTheme.Typography.badge)
                        }
                        .foregroundColor(AppTheme.Colors.primary)
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, AppTheme.Spacing.xs)
                        .background(AppTheme.Colors.primary.opacity(0.1))
                        .cornerRadius(AppTheme.Radius.sm)
                    }
                    
                    Text(profile.location)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Skill Tags
            VStack(alignment: .leading, spacing: 8) {
                if !profile.canTeach.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "graduationcap.fill")
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(AppTheme.Colors.primary)
                        Text("TEACHING: \(profile.canTeach.joined(separator: ", ").uppercased())")
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
                
                if !profile.wantsToLearn.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "lightbulb.fill")
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(AppTheme.Colors.info)
                        Text("LEARNING: \(profile.wantsToLearn.joined(separator: ", ").uppercased())")
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
            }
            
            Text("\"\(profile.bio)\"")
                .font(.system(size: 13))
                .foregroundColor(.black.opacity(0.7))
                .lineLimit(2)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}
