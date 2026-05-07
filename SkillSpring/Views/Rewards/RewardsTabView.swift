import SwiftUI

struct RewardsTabView: View {
        @StateObject private var vm = RewardsViewModel()
    @State private var showLeaderboard = false
    @State private var showAnalytics = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header with custom leaf icon
                HStack {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .accessibilityHidden(true)
                    .accessibilityHidden(true)
                    Spacer()
                    NavigationLink(destination: NotificationsView()) {
                        Image(systemName: "bell")
                            .font(AppTheme.Typography.title3)
                            .foregroundColor(.gray)
                    }
                    .accessibilityLabel("Notifications")
                    .accessibilityHint("Double-tap to view notifications")
                }
                .padding(.horizontal)
                
                // Mastery Title Area
                VStack(alignment: .leading, spacing: 4) {
                    Text("My Rewards")
                        .font(AppTheme.Typography.title)
                    Text("You are in the top 10% this month")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Mastery Hero Card Refinement
                MasteryHeroCard(data: vm.masteryData)
                    .padding(.horizontal)
                
                // Top Curators League Preview
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Top Curators")
                            .font(.headline)
                        Spacer()
                        Text("Weekly League")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(AppTheme.Colors.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.Colors.primary.opacity(0.1))
                            .cornerRadius(4)
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(Array(vm.leaderboard.prefix(3).enumerated()), id: \.offset) { index, curator in
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color(.systemGray6))
                                        .frame(width: 44, height: 44)
                                    Image(curator.avatarUrl)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 44, height: 44)
                                        .clipShape(Circle())
                                    
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 14, height: 14)
                                        .overlay(Text("\(index + 1)").font(AppTheme.Typography.badge))
                                        .offset(x: 16, y: -16)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(curator.fullName)
                                        .font(AppTheme.Typography.subheadline)
                                    Text("Expert Mentor")
                                        .font(AppTheme.Typography.caption2)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Text("\(String(format: "%.1fk", Double(curator.points)/1000.0))")
                                    .font(AppTheme.Typography.subheadline)
                                    .foregroundColor(.primary)
                                Text("POINTS")
                                    .font(.system(size: 8, weight: .black))
                                    .foregroundColor(.gray)
                            }
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.02), radius: 5)
                            .accessibilityElement(children: .combine)
                        }
                    }
                    
                    Button(action: { showLeaderboard = true }) {
                        Text("View Full Leaderboard")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.primary)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.Colors.primary.opacity(0.2), lineWidth: 1))
                    }
                    .accessibilityLabel("View Full Leaderboard")
                    .accessibilityHint("Double-tap to open the weekly leaderboard")
                    .accessibilityMinTouchTarget()
                }
                .padding(.horizontal)
                
                // Your Harvest (Refined 4-column grid)
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Your Harvest")
                            .font(.headline)
                        Spacer()
                        Text("12 of 30 collected")
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(.gray)
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 24) {
                        BadgeCell(title: "First Bloom", icon: "leaf.fill", color: .green)
                        BadgeCell(title: "Steady Growth", icon: "chart.line.uptrend.xyaxis", color: .teal)
                        BadgeCell(title: "Master Mind", icon: "brain.headlight.fill", color: .orange)
                        BadgeCell(title: "Night Owl", icon: "moon.fill", color: .indigo)
                        BadgeCell(title: "Fast Track", icon: "bolt.fill", color: .yellow)
                        BadgeCell(title: "Champion", icon: "star.fill", color: .blue)
                    }
                }
                .padding(.horizontal)
                
                // Upcoming Milestones
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Upcoming Milestones")
                            .font(.headline)
                        Spacer()
                        Button("VIEW ALL") { showAnalytics = true }
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(AppTheme.Colors.primary)
                            .accessibilityLabel("View all upcoming milestones")
                            .accessibilityMinTouchTarget()
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(vm.milestones) { milestone in
                            MilestoneRow(milestone: milestone)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Analytics Navigation
                Button(action: { showAnalytics = true }) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 44, height: 44)
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.white)
                        }
                        
                        Text("Detailed Learning Analytics")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(20)
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(24)
                    .shadow(color: AppTheme.Colors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
                .accessibilityLabel("Detailed Learning Analytics")
                .accessibilityHint("Double-tap to view your full analytics dashboard")
                
                Spacer().frame(height: 100)
            }
            .padding(.top)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .sheet(isPresented: $showLeaderboard) {
            LeaderboardView(vm: vm)
        }
        .sheet(isPresented: $showAnalytics) {
            LearningAnalyticsView(vm: vm)
        }
    }
}

struct BadgeCell: View {
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
        }
        .accessibilityElement(children: .combine)
    }
}
