import SwiftUI

struct MatchesListView: View {
    @State private var searchText = ""
    @State private var selectedCategory = "All Matches"
    let categories = ["All Matches", "Creative Arts", "Development"]
    
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
                    Text("Grow your circle.")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Suggested mentors and peers matching \nyour journey.")
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
                
                // Matches List
                VStack(spacing: 20) {
                    ForEach(MockDataProvider.shared.matchProfiles) { profile in
                        MatchesCard(profile: profile)
                    }
                }
                .padding(.horizontal)
                
                // Weekly Workshop Card
                VStack(alignment: .leading, spacing: 16) {
                    ZStack(alignment: .bottomLeading) {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(.systemGray6))
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: "person.3.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                                    .foregroundColor(.gray.opacity(0.1))
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("WEEKLY WORKSHOP")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color(hex: "00A86B"))
                            
                            Text("Public Speaking\nMasterclass")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        .padding(24)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Join 12 others this Saturday in Central Park for an open-air speech workshop.\nBeginners welcome!")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineSpacing(4)
                        
                        HStack {
                            Button(action: { /* Join action */ }) {
                                Text("Join Group")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color(hex: "00A86B"))
                                    .cornerRadius(8)
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "person.2.fill")
                                    .font(.caption2)
                                Text("8 slots left")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .padding(.horizontal)
                
                Spacer().frame(height: 100)
            }
            .padding(.top)
        }
        .navigationBarHidden(true)
    }
}
