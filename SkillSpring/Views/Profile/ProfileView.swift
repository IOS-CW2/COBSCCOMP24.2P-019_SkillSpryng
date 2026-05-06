import SwiftUI

struct ProfileView: View {
    @StateObject private var vm = ProfileViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var showAllReviews = false
    
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
                        .accessibilityLabel("Settings")
                    }
                )
                
                // Profile Hero 
                VStack(spacing: 16) {
                    ZStack(alignment: .bottomTrailing) {
                        if !vm.user.profileImageURL.isEmpty {
                            Image(vm.user.profileImageURL)
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
                        Text(vm.user.fullName)
                            .font(AppTheme.Typography.title2)
                        Text("\(vm.user.role) • Level \(vm.user.level)")
                            .font(AppTheme.Typography.callout)
                            .foregroundColor(.gray)
                        
                        Label(vm.user.location, systemImage: "mappin.circle.fill")
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }
                    .accessibilityElement(children: .combine)
                    
                    NavigationLink(destination: EditProfileView()) {
                        Text("Edit Profile")
                            .font(AppTheme.Typography.subheadline)
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
                            .font(AppTheme.Typography.subheadline)
                        Spacer()
                        Text("\(vm.user.profileCompleteness)%")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(.systemGray6))
                                .frame(height: 8)
                            Capsule()
                                .fill(AppTheme.Colors.primary)
                                .frame(width: geo.size.width * CGFloat(vm.user.profileCompleteness) / 100, height: 8)
                        }
                    }
                    .frame(height: 8)
                    
                    NavigationLink(destination: EditProfileView()) {
                        HStack(spacing: 4) {
                            Text("See what's missing")
                            Image(systemName: "arrow.right")
                        }
                        .font(AppTheme.Typography.badge)
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
                                .font(AppTheme.Typography.badge)
                                .foregroundColor(.gray)
                            Text("\(vm.user.walletBalance) SKP")
                                .font(AppTheme.Typography.headline)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(AppTheme.Typography.subheadline)
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
                        .font(AppTheme.Typography.badge)
                        .foregroundColor(AppTheme.Colors.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Stats Grid
                HStack(spacing: 12) {
                    SimplifiedStatCard(value: "\(vm.user.sessionsCount)", label: "SESSIONS")
                    SimplifiedStatCard(value: String(format: "%.1f", vm.user.rating), label: "RATING")
                    SimplifiedStatCard(value: "\(vm.user.skillsToTeach.count + vm.user.skillsToLearn.count)", label: "SKILLS")
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
                                .font(AppTheme.Typography.badge)
                                .foregroundColor(AppTheme.Colors.primary)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("TEACHES")
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(.gray)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(vm.user.skillsToTeach, id: \.self) { skill in
                                    SkillBadge.teaching(skill)
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("LEARNS")
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(.gray)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(vm.user.skillsToLearn, id: \.self) { skill in
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
                            .font(AppTheme.Typography.badge)
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
                    SectionHeader(title: "REVIEWS", actionTitle: "\(vm.user.sessionsCount) Total", action: { showAllReviews = true })
                    
                    ReviewRow(name: "Sarah Mitchell", time: "Learner of UI Design   2 days ago", comment: "Adrian is an incredible mentor. He doesn't just teach the craft, he teaches the mindset of a successful designer.", rating: 5)
                    
                    ReviewRow(name: "Julian Chen", time: "Learner of Brand Strategy • 1 week ago", comment: "Top-tier sessions. Adrian's depth of knowledge in market positioning was exactly what our startup needed.", rating: 5)
                }
                .padding(.horizontal)
                
                Spacer().frame(height: 100)
            }
            .padding(.top)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .background(
            NavigationLink(destination: GenericListView(title: "All Reviews", items: ["Sarah Mitchell: Adrian is an incredible mentor. He doesn't just teach the craft, he teaches the mindset of a successful designer.", "David Chen: Great session! Very clear explanations.", "Emma Wong: Helped me build my first iOS app from scratch."]), isActive: $showAllReviews) {
                EmptyView()
            }
        )
        .navigationBarHidden(true)
        .onAppear {
            if let cachedUser = PersistenceService.shared.fetchUser() {
                self.vm.user = cachedUser
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
                .font(AppTheme.Typography.title3)
            Text(label)
                .font(AppTheme.Typography.badge)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 5)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}
