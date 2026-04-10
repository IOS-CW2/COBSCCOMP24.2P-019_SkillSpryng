import SwiftUI

struct DiscoverView: View {
    @State private var searchText = ""
    @State private var selectedCategory = "All Learners"
    @State private var navigateToCourses = false
    @State private var navigateToSkillMatches = false
    let categories = ["All Learners", "Design", "Coding", "Marketing", "Arts", "Music"]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Image(systemName: "leaf.fill")
                        .foregroundColor(AppTheme.Colors.primary)
                        .font(.title3)
                    
                    Spacer()
                    
                    NavigationLink(destination: NotificationsView()) {
                        Image(systemName: "bell")
                            .font(.title3)
                            .foregroundColor(.gray)
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
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("What do you want to learn?", text: $searchText)
                        .font(AppTheme.Typography.body)
                    
                    Button(action: { /* Filter action */ }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(AppTheme.Radius.md)
                .padding(.horizontal)
                
                // Category Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            CategoryChip(title: category, isSelected: selectedCategory == category) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Perfect Match Card
                HeroMatchCard(action: { navigateToSkillMatches = true })
                    .padding(.horizontal)
                    .onTapGesture { navigateToSkillMatches = true }
                
                // Streak Card
                StreakCard(streakCount: 7, subheadline: "1,240 Karma • Top 5%")
                    .padding(.horizontal)
                
                // Most Popular Skills
                SkillSection(title: "Most Popular Skills", items: MockDataProvider.shared.recommendedSkills)
                
                // Recommended for you
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Recommended for you")
                            .font(AppTheme.Typography.title3)
                        Spacer()
                        Button("See all") { navigateToCourses = true }
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                    .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(MockDataProvider.shared.recommendedSkills.prefix(2)) { skill in
                            RecommendedSkillCard(skill: skill)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Post a Skill section
                PostSkillCard()
                    .padding(.horizontal)
                
                Spacer().frame(height: 100)
            }
            .padding(.top)
            
            NavigationLink(destination: SkillMatchesView(), isActive: $navigateToSkillMatches) {
                EmptyView()
            }
            
            NavigationLink(destination: CoursesView(), isActive: $navigateToCourses) {
                EmptyView()
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Subcomponents

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? AppTheme.Colors.primary : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .gray)
                .cornerRadius(20)
        }
    }
}

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
                        Image("instructor1") // Use placeholders or system icons if assets missing
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        
                        Image("instructor2")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
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
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(AppTheme.Colors.primary)
                            .cornerRadius(8)
                    }
                }
                .padding(24)
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .font(.system(size: 44))
                    .foregroundColor(AppTheme.Colors.primary.opacity(0.15))
                    .padding(.trailing, 24)
            }
        }
    }
}



struct SkillSection: View {
    let title: String
    let items: [RecommendedSkill]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(AppTheme.Typography.title3)
                Spacer()
                Button("See all") { }
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
                        .font(.system(size: 8, weight: .bold))
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
                        .font(.system(size: 16, weight: .bold))
                    Text("With \(skill.instructor) • " + String(format: "%.1f", skill.rating) + " ★")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(skill.price)
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.primary.opacity(0.1))
                    .foregroundColor(AppTheme.Colors.primary)
                    .cornerRadius(4)
            }
            .frame(width: 260)
            
            HStack {
                Label("Expert", systemImage: "star.fill")
                    .font(.system(size: 10))
                Label("Materials Included", systemImage: "briefcase.fill")
                    .font(.system(size: 10))
            }
            .foregroundColor(.gray)
        }
    }
}

struct RecommendedSkillCard: View {
    let skill: RecommendedSkill
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .aspectRatio(1.2, contentMode: .fit)
            
            Text(skill.title)
                .font(.system(size: 14, weight: .bold))
                .lineLimit(1)
            
            Text("\(skill.instructor)")
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}

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
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primary)
                    .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(AppTheme.Radius.xl)
    }
}
