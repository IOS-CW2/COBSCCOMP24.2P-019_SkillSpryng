import SwiftUI

struct SkillSetupView: View {
    @StateObject private var viewModel = SkillSetupViewModel()
    
    var fullName: String
    var phoneNumber: String
    
    @State private var navigateToProfileSetup = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            // Skip setup — mark as logged in, RootCoordinatorView switches to MainTabView
                            UserDefaults.standard.set(true, forKey: "skillspryng.isLoggedIn")
                        }) {
                            Text("Skip")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Text("What are you here for?")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Select your primary path to personalize your growth journey")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Skills to Teach")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundColor(AppTheme.Colors.primary)
                                .accessibilityHidden(true)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(viewModel.availableTeachSkills, id: \.self) { skill in
                                    SkillChip(title: skill, isSelected: viewModel.selectedTeachSkills.contains(skill)) {
                                        viewModel.toggleTeachSkill(skill)
                                    }
                                }
                            }
                        }
                        
                        Button(action: { /* Add custom skill */ }) {
                            Text("+ Add Skill")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.3)))
                        }
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Skills to Learn")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "book.fill")
                                .foregroundColor(AppTheme.Colors.primary)
                                .accessibilityHidden(true)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(viewModel.availableLearnSkills, id: \.self) { skill in
                                    SkillChip(title: skill, isSelected: viewModel.selectedLearnSkills.contains(skill)) {
                                        viewModel.toggleLearnSkill(skill)
                                    }
                                }
                            }
                        }
                        
                        Button(action: { /* Add custom skill */ }) {
                            Text("+ Add Skill")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.3)))
                        }
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("OVERALL EXPERIENCE LEVEL")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .bold()
                        
                        HStack(spacing: 8) {
                            ForEach(SkillSetupViewModel.ExperienceLevel.allCases) { level in
                                Button(action: {
                                    viewModel.experienceLevel = level
                                }) {
                                    Text(level.rawValue)
                                        .font(.subheadline)
                                        .foregroundColor(viewModel.experienceLevel == level ? AppTheme.Colors.primary : .gray)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(viewModel.experienceLevel == level ? AppTheme.Colors.primary : Color.gray.opacity(0.3), lineWidth: viewModel.experienceLevel == level ? 2 : 1)
                                        )
                                }
                                .accessibilityAddTraits(viewModel.experienceLevel == level ? .isSelected : [])
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Location")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .bold()
                            Spacer()
                            Toggle("", isOn: .constant(true)).labelsHidden()
                                .accessibilityLabel("Location context")
                        }
                        
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.gray)
                            TextField("e.g. San Francisco, CA", text: $viewModel.location)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding(24)
            }
            
            VStack(spacing: 12) {
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                
                PrimaryButton(title: "Continue →", action: {
                    navigateToProfileSetup = true
                }, isLoading: viewModel.isLoading)
                
                NavigationLink(destination: ProfileSetupView(viewModel: viewModel, fullName: fullName, phoneNumber: phoneNumber), isActive: $navigateToProfileSetup) {
                    EmptyView()
                }
            }
            .padding(24)
            .background(Color.white.shadow(color: .black.opacity(0.05), radius: 8, y: -5))
            .navigationBarHidden(true)
        }
    }
    
    struct SkillChip: View {
        var title: String
        var isSelected: Bool
        var action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text(isSelected ? "\(title) ×" : title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .black : AppTheme.Colors.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(isSelected ? Color(red: 39/255.0, green: 226/255.0, blue: 70/255.0) : AppTheme.Colors.primary.opacity(0.1))
                    .cornerRadius(16)
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
        }
    }
}
