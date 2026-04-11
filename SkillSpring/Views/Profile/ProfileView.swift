import SwiftUI

struct ProfileView: View {
    @State private var user = PersistenceService.shared.fetchUser() ?? MockDataProvider.shared.currentUser
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header Navigation
                AppHeader(title: "Profile", showBackButton: true, actionIcon: "gearshape") { }
                .overlay(
                    HStack {
                        Spacer()
                        NavigationLink(destination: SettingsView()) {
                            Color.clear.frame(width: 44, height: 44)
                        }
                    }
                )
                
                // Profile Hero 
                VStack(spacing: 16) {
                    ZStack(alignment: .bottomTrailing) {
                        if !user.profileImageURL.isEmpty {
                            Image(user.profileImageURL)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .overlay(
                                    Circle()
                                        .stroke(AppTheme.Colors.primary, lineWidth: 2)
                                        .frame(width: 108, height: 108)
                                )
                        } else {
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 100, height: 100)
                                .overlay(Image(systemName: "person.fill").font(.system(size: 40)).foregroundColor(.gray))
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .overlay(
                                    Circle()
                                        .stroke(AppTheme.Colors.primary, lineWidth: 2)
                                        .frame(width: 108, height: 108)
                                )
                        }
                        
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(AppTheme.Colors.primary)
                            .background(Color.white)
                            .clipShape(Circle())
                            .offset(x: -5, y: -5)
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
                
                // Profile Completeness
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Profile Completeness")
                            .font(.system(size: 14, weight: .bold))
                        Spacer()
                        Text("\(user.profileCompleteness)%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(.systemGray6))
                                .frame(height: 8)
                            Capsule()
                                .fill(AppTheme.Colors.primary)
                                .frame(width: geo.size.width * CGFloat(user.profileCompleteness) / 100, height: 8)
                        }
                    }
                    .frame(height: 8)
                    
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
                
                // Wallet Balance High-Fidelity
                NavigationLink(destination: WalletView()) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(AppTheme.Colors.primary.opacity(0.1))
                                .frame(width: 40, height: 40)
                            Image(systemName: "banknote.fill")
                                .foregroundColor(AppTheme.Colors.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Balance")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.gray)
                            Text("\(user.walletBalance) SKP")
                                .font(.system(size: 18, weight: .bold))
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
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
                
                // View Analytics Link
                NavigationLink(destination: LearningAnalyticsView()) {
                    Label("View Analytics", systemImage: "chart.bar.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Stats Grid
                HStack(spacing: 12) {
                    SimplifiedStatCard(value: "\(user.sessionsCount)", label: "SESSIONS")
                    SimplifiedStatCard(value: String(format: "%.1f", user.rating), label: "RATING")
                    SimplifiedStatCard(value: "\(user.skillsToTeach.count + user.skillsToLearn.count)", label: "SKILLS")
                }
                .padding(.horizontal)
                
                // My Skills Quick View
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
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(user.skillsToTeach, id: \.self) { skill in
                                    SkillBadge.teaching(skill)
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("LEARNS")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(user.skillsToLearn, id: \.self) { skill in
                                    SkillBadge.learning(skill)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Badges 
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
                
                // Reviews
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
        .onAppear {
            if let cachedUser = PersistenceService.shared.fetchUser() {
                self.user = cachedUser
            }
        }
    }
}

struct SimplifiedStatCard: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 5)
    }
}
