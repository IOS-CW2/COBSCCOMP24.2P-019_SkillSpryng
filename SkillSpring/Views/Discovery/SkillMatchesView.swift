import SwiftUI

/// Shows a full list of potential skill matches and suggested peers.
///
/// Includes search filters, category chips, and a weekly workshop highlight.
struct SkillMatchesView: View {
    @StateObject private var vm = DiscoverViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToEvents = false
    @State private var searchText = ""
    @State private var selectedCategory = "All Matches"
    let categories = ["All Matches", "Creative Arts", "Development"]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // Navigation Header
                // The top bar allows users to go back from the match list.
                AppHeader(title: "Skill Matches", backAction: { dismiss() })
                
                // Title Area
                VStack(alignment: .leading, spacing: 4) {
                    Text("Grow your circle.")
                        .font(AppTheme.Typography.largeTitle)
                    Text("Suggested mentors and peers matching your journey.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                // Search Bar
                // Lets users filter matches by people, skills, or topics.
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
                // Lightweight horizontal chips used to narrow the match list.
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
                // Each card is a tappable navigation link to the profile detail view.
                VStack(spacing: 20) {
                    ForEach(vm.profiles) { profile in
                        NavigationLink(destination: MatchDetailView(profile: profile)) {
                            SkillMatchCard(profile: profile)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityIdentifier("skillMatchCard")
                    }
                }
                .padding(.horizontal)
                
                // Weekly Workshop Card
                // Promotes a live group event and encourages users to join.
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
                                .font(AppTheme.Typography.badge)
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
                            .font(AppTheme.Typography.callout)
                            .foregroundColor(.gray)
                            .lineSpacing(4)
                        
                        HStack {
                            Button(action: { navigateToEvents = true }) {
                                Text("Join Group")
                                    .font(AppTheme.Typography.badge)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(AppTheme.Colors.primary)
                                    .cornerRadius(12)
                            }
                            
                            Label("8 slots left", systemImage: "person.2.fill")
                                .font(AppTheme.Typography.caption)
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
        .background(
            NavigationLink(destination: EventsView(), isActive: $navigateToEvents) { EmptyView() }
        )
    }
}

/// A card representing a single skill match recommendation.
/// Shows match score, location, and a short bio preview.
struct SkillMatchCard: View {
    let profile: MatchProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                SmartAvatar(imageUrl: profile.imageUrl, width: 60, height: 60)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.fullName)
                        .font(AppTheme.Typography.headline)
                    Text("\(profile.location) • \(profile.distance)")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Image(systemName: "bolt.fill")
                        .font(AppTheme.Typography.callout)
                    Text("\(profile.matchPercentage)%")
                        .font(AppTheme.Typography.badge)
                    Text("Match")
                        .font(AppTheme.Typography.caption2)
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
                .font(AppTheme.Typography.callout)
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
