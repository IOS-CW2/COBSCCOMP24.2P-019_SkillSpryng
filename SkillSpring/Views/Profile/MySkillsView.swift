import SwiftUI

struct MySkillsView: View {
    @State private var selectedTab = "Teaching"
    @State private var user = MockDataProvider.shared.currentUser
    @Environment(\.dismiss) var dismiss
    
    let tabs = ["Teaching", "Learning"]
    
    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "My Skills", backAction: { dismiss() })
            
            // Tab Switcher
            HStack(spacing: 12) {
                ForEach(tabs, id: \.self) { tab in
                    Button(action: { selectedTab = tab }) {
                        Text(tab)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(selectedTab == tab ? .white : .gray)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(selectedTab == tab ? AppTheme.Colors.primary : Color(.systemGray6))
                            .cornerRadius(20)
                    }
                }
                Spacer()
            }
            .padding()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(selectedTab == "Teaching" ? "Your Expertise" : "Interests")
                            .font(.system(size: 24, weight: .bold))
                        Text(selectedTab == "Teaching" ? 
                             "Skills you are sharing with the community." : 
                             "Skills you want to master through mentorship.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    if selectedTab == "Teaching" {
                        VStack(spacing: 20) {
                            ForEach(user.skillsToTeach, id: \.self) { skill in
                                let stats = user.skillStats[skill]
                                CredibilityCard(
                                    title: skill,
                                    score: stats?.credibilityScore ?? 0,
                                    badge: stats?.level ?? "PRO",
                                    subheadline: "\(stats?.studentsTaught ?? 0) students taught • \(stats?.rating ?? 0.0) ★",
                                    studentsTaught: stats?.studentsTaught ?? 0,
                                    rating: stats?.rating ?? 0.0
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        Button(action: { }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Teaching Skill")
                            }
                            .font(.system(size: 14, weight: .bold))
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
                            ForEach(user.skillsToLearn, id: \.self) { skill in
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(AppTheme.Colors.primary.opacity(0.1))
                                            .frame(width: 44, height: 44)
                                        Image(systemName: "sparkles")
                                            .foregroundColor(AppTheme.Colors.primary)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(skill)
                                            .font(.system(size: 16, weight: .bold))
                                        Text("Beginner • 4 lessons completed")
                                            .font(.system(size: 11))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: { }) {
                                        Text("Find Mentors")
                                            .font(.system(size: 12, weight: .bold))
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
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer().frame(height: 100)
                }
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
