import SwiftUI

struct LeaderboardView: View {
    @State private var selectedTab = "Weekly"
    @Environment(\.dismiss) var dismiss
    let data = MockDataProvider.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            AppHeader(title: "Leaderboard", backAction: { dismiss() })
            
            // Tab Switcher
            HStack(spacing: 0) {
                ForEach(["Weekly", "All Time"], id: \.self) { tab in
                    Button(action: { selectedTab = tab }) {
                        VStack(spacing: 8) {
                            Text(tab)
                                .font(.system(size: 14, weight: selectedTab == tab ? .bold : .medium))
                                .foregroundColor(selectedTab == tab ? AppTheme.Colors.primary : .gray)
                            
                            Rectangle()
                                .fill(selectedTab == tab ? AppTheme.Colors.primary : Color.clear)
                                .frame(height: 2)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Podium
                    HStack(alignment: .bottom, spacing: 20) {
                        // 2nd Place
                        PodiumMember(rank: 2, name: data.leaderboardWeekly[0].fullName, points: data.leaderboardWeekly[0].points, avatar: data.leaderboardWeekly[0].avatarUrl)
                        
                        // 1st Place
                        PodiumMember(rank: 1, name: data.leaderboardWeekly[1].fullName, points: data.leaderboardWeekly[1].points, avatar: data.leaderboardWeekly[1].avatarUrl, isLarge: true)
                        
                        // 3rd Place
                        PodiumMember(rank: 3, name: data.leaderboardWeekly[2].fullName, points: data.leaderboardWeekly[2].points, avatar: data.leaderboardWeekly[2].avatarUrl)
                    }
                    .padding(.top, 40)
                    
                    // Current User Rank
                    LeaderboardRow(entry: data.leaderboardAllTimeCurrent)
                        .padding(.horizontal)
                    
                    // List
                    VStack(spacing: 12) {
                        ForEach(4..<9) { i in
                            LeaderboardRow(entry: LeaderboardEntry(
                                fullName: ["Daniel Chen", "Emma Watson", "Robert King", "Sana Kapoor", "James Miller"][i-4],
                                points: 2500 - (i * 100),
                                rank: i,
                                avatarUrl: "instructor\(i % 2 + 1)"
                            ))
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer().frame(height: 60)
                }
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

struct PodiumMember: View {
    let rank: Int
    let name: String
    let points: Int
    let avatar: String
    var isLarge: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottom) {
                Image(avatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: isLarge ? 80 : 60, height: isLarge ? 80 : 60)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(rank == 1 ? Color.yellow : .clear, lineWidth: 3))
                
                Circle()
                    .fill(rank == 1 ? Color.yellow : (rank == 2 ? Color.gray : Color.orange))
                    .frame(width: 20, height: 20)
                    .overlay(Text("\(rank)").font(.system(size: 10, weight: .bold)).foregroundColor(.white))
                    .offset(y: 8)
            }
            
            VStack(spacing: 2) {
                Text(name)
                    .font(.system(size: 12, weight: .bold))
                Text("\(points)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primary)
            }
        }
    }
}
