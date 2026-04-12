import SwiftUI

struct MatchDetailView: View {
    let profile: MatchProfile
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // Header with Image
                ZStack(alignment: .top) {
                    Image(profile.imageUrl)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140, height: 140)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 10)
                        .accessibilityHidden(true)
                        .overlay(
                            ZStack {
                                Circle().fill(Color.white).frame(width: 24, height: 24)
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(AppTheme.Colors.primary)
                                    .font(.system(size: 20))
                            }
                            .offset(x: 45, y: 45),
                            alignment: .center
                        )
                        .padding(.top, 60)
                    
                    HStack {
                        AppHeader(title: "", backAction: { dismiss() }, actionIcon: "ellipsis", action: { })
                    }
                    .padding(.top, 40)
                }
                
                // Name & Stats Row
                VStack(spacing: 8) {
                    Text(profile.fullName)
                        .font(.system(size: 26, weight: .bold))
                    
                    Text(profile.role)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    HStack(spacing: 12) {
                        Label(profile.onlineStatus ? "ONLINE" : "OFFLINE", systemImage: "circle.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(profile.onlineStatus ? .green : .gray)
                        Label(profile.city, systemImage: "mappin.circle.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(profile.fullName). \(profile.role). \(profile.onlineStatus ? "Online" : "Offline"). In \(profile.city).")
                
                // Match Badge
                HStack {
                    Image(systemName: "bolt.fill")
                    Text("\(profile.matchPercentage)% SKILL MATCH")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppTheme.Colors.primary)
                .cornerRadius(12)
                .padding(.horizontal)
                .accessibilityElement(children: .combine)
                
                // Teach & Learn
                HStack(alignment: .top, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "CAN TEACH")
                        ForEach(profile.skillsToTeach, id: \.self) { skill in
                            SkillBadge.teaching(skill)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "WANTS TO LEARN")
                        ForEach(profile.skillsToLearn, id: \.self) { skill in
                            SkillBadge.learning(skill)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                
                // Stats Row
                HStack(spacing: 16) {
                    DetailStatCard(title: "SESSIONS", value: "\(profile.sessionsCount)")
                    DetailStatCard(title: "RATING", value: String(format: "%.1f", profile.rating), suffix: "★")
                    DetailStatCard(title: "RESPONSE", value: profile.responseTime)
                }
                .padding(.horizontal)
                
                // About
                VStack(alignment: .leading, spacing: 12) {
                    Text("About \(profile.fullName.split(separator: " ").first ?? "")")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(profile.bio)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineSpacing(6)
                }
                .padding(.horizontal)
                
                // Availability
                VStack(alignment: .leading, spacing: 16) {
                    Text("Availability")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 10) {
                        ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                            Text(day)
                                .font(.system(size: 12, weight: .bold))
                                .frame(width: 36, height: 36)
                                .background(profile.availability.contains(day) ? AppTheme.Colors.primary : Color(.systemGray6))
                                .foregroundColor(profile.availability.contains(day) ? .white : .gray)
                                .cornerRadius(8)
                        }
                    }
                    
                    HStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .foregroundColor(AppTheme.Colors.primary)
                            .padding(10)
                            .background(AppTheme.Colors.primary.opacity(0.1))
                            .cornerRadius(10)
                        
                        VStack(alignment: .leading) {
                            SectionHeader(title: "NEXT OPENING")
                            Text("Tue, Oct 24")
                                .font(.system(size: 16, weight: .bold))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "person.2.fill")
                            .foregroundColor(AppTheme.Colors.primary)
                            .padding(10)
                            .background(AppTheme.Colors.primary.opacity(0.1))
                            .cornerRadius(10)
                        
                        VStack(alignment: .leading) {
                            SectionHeader(title: "PAST MATCHES")
                            Text("14 Students")
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                }
                .padding(.horizontal)
                
                // Reviews
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "REVIEWS", actionTitle: "See All Reviews", action: { })
                    
                    ForEach(profile.reviews) { review in
                        ReviewCard(review: review)
                    }
                }
                .padding(.horizontal)
                
                Spacer().frame(height: 120)
            }
        }
        .overlay(
            VStack {
                Spacer()
                HStack(spacing: 16) {
                    NavigationLink(destination: ChatDetailView(conversation: MockDataProvider.shared.mockConversations.first(where: { $0.participant.fullName == profile.fullName }) ?? MockDataProvider.shared.mockConversations[0])) {
                        Label("Message", systemImage: "bubble.left.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.Colors.primary, lineWidth: 2))
                    }
                    
                    NavigationLink(destination: SessionBookingView(instructor: profile)) {
                        Text("Book Session ->")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.Colors.primary)
                            .cornerRadius(16)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.95))
            }
        )
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
    }
}

struct DetailStatCard: View {
    let title: String
    let value: String
    var suffix: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
            HStack(alignment: .bottom, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                if let suffix = suffix {
                    Text(suffix)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.orange)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ReviewCard: View {
    let review: UserReview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(review.reviewerImageUrl)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.reviewerName)
                        .font(.system(size: 14, weight: .bold))
                    HStack(spacing: 2) {
                        ForEach(0..<5) { i in
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(i < review.rating ? .orange : .gray.opacity(0.3))
                        }
                    }
                }
            }
            
            Text("\"\(review.comment)\"")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .italic()
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(16)
    }
}
