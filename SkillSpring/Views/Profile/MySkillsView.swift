import SwiftUI

// MARK: - MySkillsView
// Provides a tabbed view of the user's skills, separating what they teach
// from what they want to learn, with quick actions to add skills and find mentors.
struct MySkillsView: View {
    @State private var selectedTab = "Teaching"
    @StateObject private var vm = ProfileViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var navigateToMatches = false
    
    let tabs = ["Teaching", "Learning"]
    
    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "My Skills", backAction: { dismiss() })
            
            // Tab Switcher
            HStack(spacing: 12) {
                ForEach(tabs, id: \.self) { tab in
                    Button(action: { selectedTab = tab }) {
                        Text(tab)
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(selectedTab == tab ? .white : .gray)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(selectedTab == tab ? AppTheme.Colors.primary : Color(.systemGray6))
                    }
                    .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
                }
            }
            Spacer()
        }
        .padding()
        
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(selectedTab == "Teaching" ? "Your Expertise" : "Interests")
                        .font(AppTheme.Typography.title2)
                    Text(selectedTab == "Teaching" ?
                         "Skills you are sharing with the community." :
                            "Skills you want to master through mentorship.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                if selectedTab == "Teaching" {
                    VStack(spacing: 20) {
                        ForEach(vm.user.skillsToTeach, id: \.self) { skill in
                            let stats = vm.user.skillStats[skill]
                            CredibilityCard(
                                title: skill,
                                score: stats?.credibilityScore ?? 0,
                                badge: stats?.level ?? "PRO",
                                subheadline: "\(stats?.studentsTaught ?? 0) students taught • \(stats?.rating ?? 0.0) ★",
                                studentsTaught: stats?.studentsTaught ?? 0,
                                rating: stats?.rating ?? 0.0,
                                onFindLearners: { navigateToMatches = true }
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    NavigationLink(destination: EditProfileView()) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Teaching Skill")
                        }
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                } else {
                    // Learning Tab Content
                    VStack(spacing: 16) {
                        ForEach(vm.user.skillsToLearn, id: \.self) { skill in
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.Colors.primary.opacity(0.1))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "sparkles")
                                        .foregroundColor(AppTheme.Colors.primary)
                                }
                                .accessibilityHidden(true)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(skill)
                                        .font(AppTheme.Typography.headline)
                                    Text("Beginner • 4 lessons completed")
                                        .font(AppTheme.Typography.caption2)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                NavigationLink(destination: SkillMatchesView()) {
                                    Text("Find Mentors")
                                        .font(AppTheme.Typography.badge)
                                        .foregroundColor(AppTheme.Colors.primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.05), radius: 5)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.02), radius: 10)
                            .accessibilityElement(children: .combine)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer().frame(height: 100)
            }
        }
        
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
        .background(
            NavigationLink(destination: SkillMatchesView(), isActive: $navigateToMatches) { EmptyView() }
        )
    }
}


