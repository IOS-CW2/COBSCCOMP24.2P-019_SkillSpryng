import SwiftUI

struct RewardsTabView: View {
    let data = MockDataProvider.shared
    @State private var showLeaderboard = false
    @State private var showAnalytics = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Image(systemName: "leaf.fill")
                        .foregroundColor(AppTheme.Colors.primary)
                    Spacer()
                    Image(systemName: "bell")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                // Mastery Title
                VStack(alignment: .leading, spacing: 4) {
                    Text("My Rewards")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("You are in the top 10% this month")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Mastery Hero Card
                MasteryHeroCard(data: data.masteryData)
                    .padding(.horizontal)
                
                // Top Curators Preview
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Top Curators")
                            .font(.headline)
                        Spacer()
                        Text("Weekly League")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                    
                    VStack(spacing: 8) {
                        ForEach(data.topCurators.prefix(3)) { curator in
                            LeaderboardRow(entry: curator)
                        }
                    }
                    
                    Button(action: { showLeaderboard = true }) {
                        Text("View Full Leaderboard")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.Colors.primary, lineWidth: 1))
                    }
                }
                .padding(.horizontal)
                
                // Your Harvest (Badges)
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Your Harvest")
                            .font(.headline)
                        Spacer()
                        Text("12 of 30 collected")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.gray)
                    }
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(data.rewardBadges) { badge in
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: badge.colorHex).opacity(0.1))
                                        .frame(width: 50, height: 50)
                                    Image(systemName: badge.iconName)
                                        .foregroundColor(Color(hex: badge.colorHex))
                                }
                                Text(badge.title)
                                    .font(.system(size: 10, weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Upcoming Milestones
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Upcoming Milestones", actionTitle: "VIEW ALL", action: { })
                    
                    VStack(spacing: 12) {
                        ForEach(data.milestones) { milestone in
                            MilestoneRow(milestone: milestone)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Analytics Shortcut
                Button(action: { showAnalytics = true }) {
                    HStack {
                        Image(systemName: "chart.bar.xaxis")
                        Text("Detailed Learning Analytics")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(16)
                }
                .padding(.horizontal)
                
                Spacer().frame(height: 100)
            }
            .padding(.top)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .sheet(isPresented: $showLeaderboard) {
            LeaderboardView()
        }
        .sheet(isPresented: $showAnalytics) {
            LearningAnalyticsView()
        }
    }
}
