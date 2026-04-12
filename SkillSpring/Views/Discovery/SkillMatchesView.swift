import SwiftUI

struct SkillMatchesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory = "All Matches"
    let categories = ["All Matches", "Creative Arts", "Development"]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // Navigation Header
                AppHeader(title: "Skill Matches", backAction: { dismiss() })
                
                // Title Area
                VStack(alignment: .leading, spacing: 4) {
                    Text("Grow your circle.")
                        .font(.system(size: 32, weight: .bold))
                    Text("Suggested mentors and peers matching your journey.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search skills, people, or topics", text: $searchText)
                        .font(.body)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Category Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            FilterChip(title: category, isSelected: selectedCategory == category) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Matches List
                VStack(spacing: 20) {
                    ForEach(MockDataProvider.shared.matchProfiles) { profile in
                        NavigationLink(destination: MatchDetailView(profile: profile)) {
                            SkillMatchCard(profile: profile)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                
                // Weekly Workshop Card
                VStack(alignment: .leading, spacing: 16) {
                    ZStack(alignment: .bottomLeading) {
                        Image("event_ui") // Placeholder for workshop image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .overlay(Color.black.opacity(0.3).cornerRadius(24))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("WEEKLY WORKSHOP")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(AppTheme.Colors.accent)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(4)
                            
                            Text("Public Speaking\nMasterclass")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(24)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Join 12 others this Saturday in Central Park for an open-air speech workshop. Beginners welcome!")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .lineSpacing(4)
                        
                        HStack {
                            Button(action: { }) {
                                Text("Join Group")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(AppTheme.Colors.primary)
                                    .cornerRadius(12)
                            }
                            
                            Label("8 slots left", systemImage: "person.2.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .padding(.leading, 8)
                        }
                    }
                }
                .padding(.horizontal)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Weekly Workshop. Public Speaking Masterclass. Join 12 others this Saturday in Central Park for an open-air speech workshop. Beginners welcome! 8 slots left.")
                .accessibilityAddTraits(.isButton)
                .accessibilityHint("Double-tap to join group")
                
                Spacer().frame(height: 100)
            }
            .padding(.top)
        }
        .navigationBarHidden(true)
    }
}

struct SkillMatchCard: View {
    let profile: MatchProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                Image(profile.imageUrl)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.fullName)
                        .font(.system(size: 18, weight: .bold))
                    Text("\(profile.location) • \(profile.distance)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 14))
                    Text("\(profile.matchPercentage)%")
                        .font(.system(size: 12, weight: .bold))
                    Text("Match")
                        .font(.system(size: 8))
                }
                .foregroundColor(AppTheme.Colors.accent)
                .padding(8)
                .background(AppTheme.Colors.accent.opacity(0.1))
                .cornerRadius(12)
            }
            
            HStack(spacing: 8) {
                SkillBadge.teaching(profile.skillsToTeach.first ?? "")
                SkillBadge.learning(profile.skillsToLearn.first ?? "")
            }
            
            Text("\"\(profile.bio.prefix(80))...\"")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .italic()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(profile.fullName). \(profile.location), \(profile.distance) away. \(profile.matchPercentage) percent match. Bio: \(profile.bio)")
    }
}
