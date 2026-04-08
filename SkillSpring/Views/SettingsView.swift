import SwiftUI

struct SettingsView: View {
    @State private var user = MockDataProvider.shared.currentUser
    @State private var pushNotifications = true
    @State private var darkMode = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Settings & Privacy", backAction: { dismiss() })
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // User Profile Brief
                    VStack(spacing: 12) {
                        Image(user.profileImageURL)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                        
                        VStack(spacing: 4) {
                            Text(user.fullName)
                                .font(.system(size: 20, weight: .bold))
                            Text("\(user.role) • Level \(user.level)")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        // Search bar placeholder
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search settings", text: .constant(""))
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Account & Security Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "ACCOUNT & SECURITY")
                        
                        VStack(spacing: 0) {
                            SettingsRow(icon: "person.fill", title: "Personal Information")
                            Divider().padding(.leading, 48)
                            SettingsRow(icon: "lock.fill", title: "Password & Security")
                        }
                        .padding(.horizontal)
                        .background(Color.white)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    
                    // Subscription Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "SUBSCRIPTION")
                        
                        SettingsRow(icon: "crown.fill", title: "SkillSpryng Pro", value: "Active • Renews Dec 1")
                            .padding(.horizontal)
                            .background(Color.white)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    
                    // Wallet Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "WALLET")
                        
                        SettingsRow(icon: "w.square.fill", title: "SkillCredits Wallet", value: "4,850 SKP")
                            .padding(.horizontal)
                            .background(Color.white)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    
                    // Preferences Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "PREFERENCES")
                        
                        VStack(spacing: 0) {
                            SettingsRow(icon: "bell.fill", title: "Push Notifications", toggleValue: $pushNotifications)
                            Divider().padding(.leading, 48)
                            SettingsRow(icon: "moon.fill", title: "Dark Mode", toggleValue: $darkMode)
                        }
                        .padding(.horizontal)
                        .background(Color.white)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    
                    // Privacy & Safety Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            SectionHeader(title: "PRIVACY & SAFETY")
                            Spacer()
                            StatusBadge(text: "ENHANCED", color: .green)
                        }
                        
                        VStack(spacing: 0) {
                            // Profile Visibility Toggle row style from mockup
                            HStack {
                                Text("PROFILE VISIBILITY")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.gray)
                                Spacer()
                                HStack(spacing: 0) {
                                    Text("Public").padding(.horizontal, 12).padding(.vertical, 6).background(AppTheme.Colors.primary).foregroundColor(.white).cornerRadius(4)
                                    Text("Private").padding(.horizontal, 12).padding(.vertical, 6).foregroundColor(.gray)
                                    Text("Mutuals").padding(.horizontal, 12).padding(.vertical, 6).foregroundColor(.gray)
                                }
                                .background(Color(.systemGray6))
                                .cornerRadius(6)
                            }
                            .padding()
                            
                            Divider()
                            
                            NavigationLink(destination: ChildSafetyView()) {
                                SettingsRow(icon: "shield.lefthalf.filled", title: "Child Safety Mode", toggleValue: .constant(true))
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider().padding(.leading, 48)
                            
                            SettingsRow(icon: "person.badge.plus", title: "Add Family Member", toggleValue: .constant(true))
                        }
                        .padding(.horizontal)
                        .background(Color.white)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    
                    // Danger Zone
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "DANGER ZONE")
                        
                        VStack(spacing: 0) {
                            SettingsRow(icon: "trash.fill", title: "Delete Account")
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal)
                        .background(Color.white)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    
                    // Log Out
                    Button(action: { }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Log Out")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    
                    VStack(spacing: 4) {
                        Text("SkillSpryng Version 2.0.1 (103)")
                        Text("© 2024 Skill Spryng Inc.")
                    }
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .padding(.bottom, 40)
                    
                    Spacer().frame(height: 60)
                }
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
