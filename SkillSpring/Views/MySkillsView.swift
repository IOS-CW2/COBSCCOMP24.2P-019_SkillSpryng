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
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
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
                    .padding(.top)
                    
                    if selectedTab == "Teaching" {
                        VStack(spacing: 20) {
                            CredibilityCard(title: "Creative Design", score: 85, badge: "EXPERT", subheadline: "12 students taught • 4.9 ★")
                            
                            CredibilityCard(title: "UI Engineering", score: 62, badge: "PRO", subheadline: "24 students taught • 5.0 ★")
                        }
                        .padding(.horizontal)
                        
                        Button(action: { }) {
                            Text("+ Add Teaching Skill")
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
                                    SkillBadge.learning(skill)
                                    Spacer()
                                    Button("Find Mentors") { }
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(AppTheme.Colors.primary)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.02), radius: 5)
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
