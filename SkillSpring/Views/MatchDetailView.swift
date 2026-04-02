import SwiftUI

struct MatchDetailView: View {
    let profile: MatchProfile
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // Header Image & Back Button (Overlay)
                ZStack(alignment: .top) {
                    Circle()
                        .fill(Color(.systemGray6))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60)
                                .foregroundColor(.gray.opacity(0.3))
                        )
                        .padding(.top, 40)
                    
                    HStack {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(AppTheme.Colors.primary)
                                .padding()
                                .background(Circle().fill(Color.white).shadow(radius: 2))
                        }
                        Spacer()
                        Button(action: { /* Share action */ }) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(AppTheme.Colors.primary)
                                .padding()
                                .background(Circle().fill(Color.white).shadow(radius: 2))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, AppTheme.Spacing.sm)
                }
                
                // Name & Role
                VStack(spacing: 8) {
                    Text(profile.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(profile.role)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    HStack(spacing: 12) {
                        Label("ONLINE", systemImage: "circle.fill")
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(AppTheme.Colors.success)
                        Label(profile.city, systemImage: "mappin.circle.fill")
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    .padding(.top, AppTheme.Spacing.xs)
                }
                .frame(maxWidth: .infinity)
                
                // Skill Match Bar
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(AppTheme.Colors.primaryLight)
                        Text("\(profile.matchPercentage)% SKILL MATCH")
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.Colors.primary.opacity(0.1))
                    .cornerRadius(AppTheme.Radius.md)
                }
                .padding(.horizontal)
                
                // Teach & Learn Sections
                HStack(alignment: .top, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("CAN TEACH")
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        
                        ForEach(profile.canTeach, id: \.self) { skill in
                            TagView(title: skill, color: AppTheme.Colors.primary.opacity(0.1), textColor: AppTheme.Colors.primary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("WANTS TO LEARN")
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        
                        ForEach(profile.wantsToLearn, id: \.self) { skill in
                            TagView(title: skill, color: AppTheme.Colors.info.opacity(0.1), textColor: AppTheme.Colors.info)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                
                // Stats
                HStack(spacing: 16) {
                    StatCard(title: "SESSIONS", value: "128", subValue: nil, iconName: nil)
                    StatCard(title: "RATING", value: "4.9", subValue: "★", iconName: nil)
                    StatCard(title: "RESPONSE", value: "2h", subValue: nil, iconName: nil)
                }
                .padding(.horizontal)
                
                // About section
                VStack(alignment: .leading, spacing: 12) {
                    Text("About \(profile.name.split(separator: " ").first ?? "")")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(profile.bio)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                }
                .padding(.horizontal)
                
                // Availability section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Availability")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    HStack {
                        ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                            Text(day)
                                .font(AppTheme.Typography.badge)
                                .frame(width: 32, height: 32)
                                .background(day == "W" || day == "T" ? AppTheme.Colors.primary : AppTheme.Colors.surfaceLight)
                                .foregroundColor(day == "W" || day == "T" ? .white : AppTheme.Colors.textSecondary)
                                .cornerRadius(AppTheme.Radius.sm)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                        VStack(alignment: .leading) {
                            Text("NEXT OPENING")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.gray)
                            Text("Tue, Oct 24")
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                }
                .padding(.horizontal)
                
                // Bottom Buttons
                HStack(spacing: 16) {
                    Button(action: { /* Message action */ }) {
                        Label("Message", systemImage: "bubble.left.fill")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.primary)
                            .frame(maxWidth: 120)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: AppTheme.Radius.md).stroke(AppTheme.Colors.primary, lineWidth: 1))
                    }
                    
                    PrimaryButton(title: "Request Match ->") {
                        /* Request action */
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }
}

struct TagView: View {
    let title: String
    let color: Color
    let textColor: Color
    
    var body: some View {
        Text(title)
            .font(.system(size: 10, weight: .bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color)
            .foregroundColor(textColor)
            .cornerRadius(8)
    }
}
