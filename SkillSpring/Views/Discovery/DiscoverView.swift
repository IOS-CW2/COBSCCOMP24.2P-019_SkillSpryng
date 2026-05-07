import SwiftUI

/// The main discovery screen where users search for skills, browse categories,
/// and explore recommended matches or nearby instructors.
///
/// This view is a high-level orchestrator for the discovery feed and routes
/// to other screens such as map view, skill matches, and courses.
struct DiscoverView: View {
    @StateObject private var viewModel = DiscoverViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                // Top bar with logo and notification access for the discovery tab.
                HStack {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .accessibilityHidden(true)
                    
                    Spacer()
                    
                    NavigationLink(destination: NotificationsView()) {
                        Image(systemName: "bell")
                            .font(.title3)
                            .foregroundColor(.gray)
                            .accessibilityLabel("Notifications")
                    }
                }
                .padding(.horizontal)
                
                // Title Area
                VStack(alignment: .leading, spacing: 4) {
                    Text("Discover")
                        .font(AppTheme.Typography.largeTitle)
                    Text("Find partners to grow your skills today.")
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                // Search Bar
                // Lets the user search by skill, topic, or instructor name.
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .accessibilityHidden(true)
                    TextField("What do you want to learn?", text: $viewModel.searchText)
                        .font(AppTheme.Typography.body)
                        .accessibilityIdentifier("discoverSearchField")
                    
                    Button(action: { /* Filter action */ }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(AppTheme.Colors.primary)
                            .accessibilityLabel("Filter search")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(AppTheme.Radius.md)
                .padding(.horizontal)
                
                // Category Filters
                // Quick filter chips to narrow discovery results by interest area.
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            CategoryChip(title: category, isSelected: viewModel.selectedCategory == category) {
                                viewModel.selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Perfect Match Card
                // Highlights a strong recommended connection and encourages users
                // to open the matching experience.
                HeroMatchCard(action: { viewModel.navigateToSkillMatches = true })
                    .padding(.horizontal)
                    .onTapGesture { viewModel.navigateToSkillMatches = true }
                
                // Streak Card
                StreakCard(streakCount: 7, subheadline: "1,240 Karma • Top 5%")
                    .padding(.horizontal)
                
                // Nearby Skills Map Banner
                NearbyMapBannerCard(action: { viewModel.navigateToMap = true })
                    .padding(.horizontal)
                
                if viewModel.filteredSkills.isEmpty {
                    // Empty state when the search/filter criteria return no matches.
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "No Skills Found",
                        message: "We couldn't find any skills matching your search. Try different keywords or browse categories.",
                        actionTitle: "Clear Search",
                        action: { viewModel.searchText = "" }
                    )
                } else {
                    // Most Popular Skills
                    SkillSection(title: "Most Popular Skills", items: viewModel.filteredSkills, onSeeAll: { viewModel.navigateToSkillMatches = true })
                    
                    // Recommended for you
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Recommended for you")
                                .font(AppTheme.Typography.title3)
                            Spacer()
                            Button("See all") { viewModel.navigateToCourses = true }
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.primary)
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(viewModel.filteredSkills.prefix(2)) { skill in
                                RecommendedSkillCard(skill: skill)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Post a Skill section
                PostSkillCard()
                    .padding(.horizontal)
                
                Spacer().frame(height: 100)
            }
            .padding(.top)
            
            NavigationLink(destination: SkillMatchesView(), isActive: $viewModel.navigateToSkillMatches) {
                EmptyView()
            }
            NavigationLink(destination: CoursesView(), isActive: $viewModel.navigateToCourses) {
                EmptyView()
            }
            NavigationLink(destination: LocationMapView(), isActive: $viewModel.navigateToMap) {
                EmptyView()
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Subcomponents

/// A reusable filter chip used in the discover category row.
/// Highlights the current selection and updates the selected category when tapped.
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Typography.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? AppTheme.Colors.primary : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .gray)
                .cornerRadius(20)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
        }
    }
}

/// A featured hero card showing a perfect local match.
/// Tapping it encourages the user to connect and explore skill matches.
struct HeroMatchCard: View {
    var action: () -> Void = {}
    
    var body: some View {
        ZStack(alignment: .leading) {

            RoundedRectangle(cornerRadius: 24)
                .fill(AppTheme.Gradients.heroCard)
                .frame(height: 180)
            
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    // Overlapping avatars
                    HStack(spacing: -12) {
                        SmartAvatar(imageUrl: "instructor1", width: 40, height: 40)
                        SmartAvatar(imageUrl: "instructor2", width: 40, height: 40)
                    }
                    
                    Text("Perfect Match Nearby!")
                        .font(AppTheme.Typography.headline)
                    
                    Text("Elena also wants to learn UI Design and can teach Pottery.")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: 180, alignment: .leading)
                    
                    Button(action: action) {
                        Text("Connect Now")
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(AppTheme.Colors.primary)
                            .cornerRadius(8)
                    }
                    .accessibilityIdentifier("connectNowButton")
                }
                .padding(24)
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .font(.system(size: 44))
                    .foregroundColor(AppTheme.Colors.primary.opacity(0.15))
                    .padding(.trailing, 24)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Perfect Match Nearby! Elena also wants to learn UI Design and can teach Pottery.")
            .accessibilityAddTraits(.isButton)
            .accessibilityHint("Double-tap to connect")
        }
    }
}



/// Displays a horizontal scroll section of recommended skills.
/// Each section includes a title and optional "See all" action.
struct SkillSection: View {
    let title: String
    let items: [RecommendedSkill]
    var onSeeAll: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(AppTheme.Typography.title3)
                Spacer()
                Button("See all") { onSeeAll() }
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.primary)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(items) { skill in
                        LargeSkillCard(skill: skill)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

/// A large, prominent skill card used in the "Most Popular Skills" carousel.
/// It shows the skill title, instructor, rating, and pricing badge.
struct LargeSkillCard: View {
    let skill: RecommendedSkill
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .frame(width: 260, height: 160)
                
                if skill.isTopRated {
                    Text("TOP RATED")
                        .font(AppTheme.Typography.badge)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange)
                        .cornerRadius(4)
                        .padding(12)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(skill.title)
                        .font(AppTheme.Typography.headline)
                        .lineLimit(1)
                    Text("With \(skill.instructor) • " + String(format: "%.1f", skill.rating) + " ★")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(skill.price)
                    .font(AppTheme.Typography.badge)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.primary.opacity(0.1))
                    .foregroundColor(AppTheme.Colors.primary)
                    .cornerRadius(4)
            }
            .frame(width: 260)
            
            HStack {
                Label("Expert", systemImage: "star.fill")
                    .font(AppTheme.Typography.caption2)
                Label("Materials Included", systemImage: "briefcase.fill")
                    .font(AppTheme.Typography.caption2)
            }
            .foregroundColor(.gray)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(skill.title). With \(skill.instructor). \(String(format: "%.1f", skill.rating)) stars. \(skill.price). \(skill.isTopRated ? "Top Rated. " : "")Expert. Materials Included.")
        .accessibilityAddTraits(.isButton)
    }
}

/// A compact card used for the "Recommended for you" section.
/// Shows the skill title with instructor attribution.
struct RecommendedSkillCard: View {
    let skill: RecommendedSkill
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .aspectRatio(1.2, contentMode: .fit)
            
            Text(skill.title)
                .font(AppTheme.Typography.subheadline)
                .lineLimit(1)
            
            Text("\(skill.instructor)")
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}

/// Call-to-action card prompting users to post a new skill if nothing matches.
/// Encourages engagement by letting learners create their own listing.
struct PostSkillCard: View {
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Circle()
                .stroke(AppTheme.Colors.primary, lineWidth: 1)
                .frame(width: 44, height: 44)
                .overlay(Image(systemName: "plus").foregroundColor(AppTheme.Colors.primary))
            
            VStack(spacing: 4) {
                Text("Didn't find your skill?")
                    .font(.headline)
                Text("Create a new listing and let the experts find you.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: { /* Post action */ }) {
                Text("Post a Skill")
                    .font(AppTheme.Typography.badge)
                    .foregroundColor(AppTheme.Colors.primary)
                    .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(AppTheme.Radius.xl)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Didn't find your skill? Create a new listing and let the experts find you.")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Nearby Map Banner

/// A banner card linking the user to the nearby skill map view.
/// This is a visual prompt to explore in-person or nearby opportunities.
struct NearbyMapBannerCard: View {
    var action: () -> Void = {}
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Map icon cluster
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppTheme.Colors.primary.opacity(0.12))
                        .frame(width: 56, height: 56)
                    Image(systemName: "map.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppTheme.Colors.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Skills Near You")
                        .font(AppTheme.Typography.headline)
                    Text("See instructors on the map in your area")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: -8) {
                        let images = ["instructor1", "instructor2", "instructor1"]
                        ForEach(images.indices, id: \.self) { index in
                            Image(images[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 22, height: 22)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                        }
                        Text("  +3 nearby")
                            .font(AppTheme.Typography.footnote)
                            .foregroundColor(AppTheme.Colors.primary)
                            .padding(.leading, 12)
                    }
                    .padding(.top, 2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(AppTheme.Typography.footnote)
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Skills Near You. See instructors on the map in your area. 3 nearby.")
        .accessibilityHint("Double-tap to open map")
    }
}

