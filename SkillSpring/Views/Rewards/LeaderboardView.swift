import SwiftUI

struct LeaderboardView: View {
    @State private var selectedTab = "Weekly"
    @Environment(\.dismiss) var dismiss
    let data = MockDataProvider.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            AppHeader(title: "Leaderboard", backAction: { dismiss() })
            
            // Tab Switcher Refinement
            HStack(spacing: 0) {
                ForEach(["Weekly", "All Time"], id: \.self) { tab in
                    Button(action: { selectedTab = tab }) {
                        VStack(spacing: 8) {
                            Text(tab)
                                .font(.system(size: 14, weight: selectedTab == tab ? .black : .bold))
                                .foregroundColor(selectedTab == tab ? AppTheme.Colors.primary : .gray)
                                .padding(.top, 12)
                            
                            Capsule()
                                .fill(selectedTab == tab ? AppTheme.Colors.primary : Color.clear)
                                .frame(width: 40, height: 3)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
                }
            }
            .padding(.bottom, 24)
            .background(Color.white)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 40) {
                    // Top 3 Podium
                    HStack(alignment: .bottom, spacing: 10) {
                        // 2nd Place
                        PodiumMember(
                            rank: 2, 
                            name: "Marcus T.", 
                            points: 2840, 
                            avatar: "instructor1",
                            role: "Master Curator"
                        )
                        
                        // 1st Place
                        PodiumMember(
                            rank: 1, 
                            name: "Sarah Jenkins", 
                            points: 3120, 
                            avatar: "instructor2", 
                            role: "Grandmaster",
                            isLarge: true
                        )
                        
                        // 3rd Place
                        PodiumMember(
                            rank: 3, 
                            name: "Liam W.", 
                            points: 2710, 
                            avatar: "instructor1",
                            role: "Elite Mentor"
                        )
                    }
                    .padding(.top, 20)
                    
                    // You Area (Rank #24)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.Colors.primary.opacity(0.1))
                                    .frame(width: 40, height: 40)
                                Text("#24")
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(AppTheme.Colors.primary)
                            }
                            
                            Image(data.currentUser.profileImageURL)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 48, height: 48)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(AppTheme.Colors.primary, lineWidth: 2))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("You (Alex)")
                                    .font(AppTheme.Typography.headline)
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.up.right")
                                        .font(AppTheme.Typography.badge)
                                    Text("+3 this week")
                                        .font(AppTheme.Typography.badge)
                                }
                                .foregroundColor(AppTheme.Colors.primary)
                            }
                            
                            Spacer()
                            
                            Text("1,450")
                                .font(.system(size: 18, weight: .black))
                        }
                        .padding()
                        .background(AppTheme.Colors.primary.opacity(0.05))
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.Colors.primary.opacity(0.1), lineWidth: 1))
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("You, Alex. Rank 24. 1,450 points")
                    }
                    .padding(.horizontal)
                    
                    // The rest of the leaderboard
                    VStack(spacing: 12) {
                        ForEach(4..<10) { rank in
                            LeaderboardListRow(
                                rank: rank,
                                name: ["Daniel Chen", "Emma Watson", "Robert King", "Sana Kapoor", "James Miller", "Chris Pratt"][rank-4],
                                role: ["Product Designer", "Marketing Lead", "Software Engineer", "UX Researcher", "Sales Manager", "DevOps Engineer"][rank-4],
                                points: 2500 - (rank * 80)
                            )
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

struct LeaderboardListRow: View {
    let rank: Int
    let name: String
    let role: String
    let points: Int
    
    var body: some View {
        HStack(spacing: 16) {
            Text("\(rank)")
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(.gray)
                .frame(width: 24)
            
            Image("instructor\(rank % 2 + 1)")
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(AppTheme.Typography.subheadline)
                Text(role)
                    .font(AppTheme.Typography.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("\(points.formatted())")
                .font(.system(size: 14, weight: .black))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 5)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Rank \(rank), \(name), \(role). \(points) points")
    }
}
