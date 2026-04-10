import SwiftUI

struct ProfileView: View {
    @State private var user = MockDataProvider.shared.currentUser
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header Navigation
                AppHeader(title: "Profile", showBackButton: true, actionIcon: "gearshape") {
                    // Navigate to Settings - this will happen via the action button if I wrap the header or use a state
                }
                .overlay(
                    HStack {
                        Spacer()
                        NavigationLink(destination: SettingsView()) {
                            Color.clear.frame(width: 44, height: 44)
                        }
                    }
                )
                
                // Profile Hero Card
                VStack(spacing: 16) {
                    ZStack(alignment: .bottomTrailing) {
                        Image(user.profileImageURL)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 5)
                        
                        Button(action: { }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(AppTheme.Colors.accent)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        }
                    }
                    
                    VStack(spacing: 4) {
                        Text(user.fullName)
                            .font(.system(size: 24, weight: .bold))
                        Text("\(user.role) • Level \(user.level)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Label(user.location, systemImage: "mappin.circle.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }
                    
                    NavigationLink(destination: EditProfileView()) {
                        Text("Edit Profile")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.Colors.primary)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                
                // Completion Progress
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Profile Completeness")
                            .font(.system(size: 14, weight: .bold))
                        Spacer()
                        Text("\(user.profileCompleteness)%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                    
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.systemGray6))
                            .frame(height: 8)
                        Capsule()
                            .fill(AppTheme.Colors.primary)
                            .frame(width: 300 * CGFloat(user.profileCompleteness) / 100, height: 8)
                    }
                    
                    Button(action: { }) {
                        HStack(spacing: 4) {
                            Text("See what's missing")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.3))
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Wallet Balance
                HStack {
                    Image(systemName: "creditcard.fill")
                        .foregroundColor(AppTheme.Colors.primary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Balance")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                        Text("\(user.walletBalance) SKP")
                            .font(.system(size: 16, weight: .bold))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.gray.opacity(0.5))
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
                .padding(.horizontal)
                
                // Stats Row
                ProfileStatRow(sessions: user.sessionsCount, rating: user.rating, awards: user.awardsCount)
                    .padding(.horizontal)
                
                // My Skills Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("My Skills")
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                        NavigationLink(destination: MySkillsView()) {
                            Text("View All")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppTheme.Colors.primary)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("TEACHES")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(user.skillsToTeach, id: \.self) { skill in
                                SkillBadge.teaching(skill)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("LEARNS")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(user.skillsToLearn, id: \.self) { skill in
                                SkillBadge.learning(skill)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Badges Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Badges")
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                        Button("View All") { }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            BadgeIcon(title: "Top 1%", icon: "crown.fill", color: .yellow)
                            BadgeIcon(title: "30 Day Streak", icon: "flame.fill", color: .orange)
                            BadgeIcon(title: "Master", icon: "star.fill", color: .blue)
                            BadgeIcon(title: "Helping Hand", icon: "hand.raised.fill", color: .purple)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Reviews Section
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "REVIEWS", actionTitle: "42 Total", action: { })
                    
                    ReviewRow(name: "Sarah Mitchell", time: "Learner of UI Design • 2 days ago", comment: "Adrian is an incredible mentor. He doesn't just teach the craft, he teaches the mindset of a successful designer.", rating: 5)
                    
                    ReviewRow(name: "Julian Chen", time: "Learner of Brand Strategy • 1 week ago", comment: "Top-tier sessions. Adrian's depth of knowledge in market positioning was exactly what our startup needed.", rating: 5)
                }
                .padding(.horizontal)
                
                Spacer().frame(height: 100)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

// MARK: - Supporting Views

struct BadgeIcon: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().fill(color.opacity(0.1)).frame(width: 50, height: 50)
                Image(systemName: icon).foregroundColor(color)
            }
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
        }
        .frame(width: 80)
    }
}

struct ReviewRow: View {
    let name: String
    let time: String
    let comment: String
    let rating: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image("instructor1") // Placeholder
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.system(size: 14, weight: .bold))
                    Text(time)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(0..<5) { i in
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                            .foregroundColor(i < rating ? .orange : Color(.systemGray4))
                    }
                }
            }
            
            Text(comment)
                .font(.system(size: 13, weight: .medium))
                .lineSpacing(4)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }
}

struct FlowLayout: View {
    let spacing: CGFloat
    let items: () -> [AnyView]
    
    init(spacing: CGFloat, @ViewBuilder content: @escaping () -> some View) {
        self.spacing = spacing
        // Simplification for flow layout in this demo
        self.items = { [] }
    }
    
    // Using a simpler HStack for demo purposes as FlowLayout is complex to implement generically without custom ViewLayout
    var body: some View {
        HStack {
            // Placeholder for flow logic
        }
    }
}

// Simplified version for the badges row to avoid complex flow layout in demo
struct SkillBadgeRow: View {
    let skills: [String]
    let type: String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(skills, id: \.self) { skill in
                    if type == "teaching" {
                        SkillBadge.teaching(skill)
                    } else {
                        SkillBadge.learning(skill)
                    }
                }
            }
        }
    }
}

// Temporary EditProfileView
struct EditProfileView: View {
    var body: some View {
        Text("Edit Profile Content")
    }
}
