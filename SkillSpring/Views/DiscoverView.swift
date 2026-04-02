import SwiftUI

struct DiscoverView: View {
    @State private var searchText = ""
    @State private var selectedCategory = "All Learners"
    let categories = ["All Learners", "Design", "Coding", "Marketing"]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    Text("SkillSpryng")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "00A86B"))
                    Spacer()
                    Image(systemName: "bell")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                // Title Area
                VStack(alignment: .leading, spacing: 4) {
                    Text("Discover")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Find partners to grow your skills today.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("What do you want to learn?", text: $searchText)
                        .font(.body)
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(Color(hex: "00A86B"))
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Category Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: { selectedCategory = category }) {
                                Text(category)
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(selectedCategory == category ? Color(hex: "00A86B") : Color(.systemGray6))
                                    .foregroundColor(selectedCategory == category ? .white : .gray)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Perfect Match Card
                HeroMatchCard()
                    .padding(.horizontal)
                
                // Recommended Section Header
                HStack {
                    Text("Recommended for you")
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                    Text("See all")
                        .font(.caption)
                        .foregroundColor(Color(hex: "00A86B"))
                }
                .padding(.horizontal)
                
                // Recommended Grid/List
                VStack(spacing: 16) {
                    ForEach(MockDataProvider.shared.recommendedSkills) { skill in
                        SkillRecommendationRow(skill: skill)
                    }
                }
                .padding(.horizontal)
                
                // Post a Skill section
                VStack(alignment: .center, spacing: 12) {
                    Circle()
                        .fill(Color(.systemGray6))
                        .frame(width: 44, height: 44)
                        .overlay(Image(systemName: "plus").bold().foregroundColor(Color(hex: "00A86B")))
                    
                    VStack(spacing: 4) {
                        Text("Not finding your skill?")
                            .font(.headline)
                        Text("Create a new listing and let the experts find you.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: { /* Post action */ }) {
                        Text("Post a Skill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(hex: "00A86B"))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(24)
                .padding(.horizontal)
                
                Spacer().frame(height: 100)
            }
            .padding(.top)
        }
        .navigationBarHidden(true)
    }
}

// Sub-components
struct HeroMatchCard: View {
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 24)
                .fill(LinearGradient(gradient: Gradient(colors: [Color(hex: "3AC45A").opacity(0.1), Color(hex: "00A86B").opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 180)
            
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: -8) {
                        Circle().fill(.gray).frame(width: 32, height: 32).overlay(Image(systemName: "person.fill").foregroundColor(.white))
                        Circle().fill(.gray).frame(width: 32, height: 32).overlay(Image(systemName: "person.fill").foregroundColor(.white))
                    }
                    
                    Text("Perfect Match Nearby!")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Elena also wants to learn UI Design and can teach Pottery.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(width: 160)
                    
                    Button(action: { /* Connect action */ }) {
                        Text("Connect Now")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(hex: "00A86B"))
                            .cornerRadius(8)
                    }
                }
                .padding(24)
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60)
                    .foregroundColor(Color(hex: "00A86B").opacity(0.2))
                    .padding()
            }
        }
    }
}

struct SkillRecommendationRow: View {
    let skill: RecommendedSkill
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .frame(height: 180)
                
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
                
                Image(systemName: "heart")
                    .foregroundColor(.white)
                    .padding(12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(skill.title)
                        .font(.headline)
                    Text("With \(skill.instructor) • \(skill.rating) ★")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(skill.price)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "00A86B"))
                    .cornerRadius(4)
            }
            
            HStack {
                Text("Expert")
                    .font(.system(size: 10))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .cornerRadius(4)
                
                Text("Materials Included")
                    .font(.system(size: 10))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .cornerRadius(4)
            }
            .foregroundColor(.gray)
        }
    }
}
