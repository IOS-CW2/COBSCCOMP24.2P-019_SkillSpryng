import SwiftUI

struct SettingsView: View {
    @State private var user = MockDataProvider.shared.currentUser
    @State private var pushNotifications = true
    @State private var darkMode = false
    @ObservedObject private var biometricService = BiometricAuthService.shared
    @AppStorage("skillspryng.isLoggedIn") private var isLoggedIn = false
    @Environment(\.dismiss) var dismiss
    
    // Toast & confirmation state
    @State private var toast: ToastMessage? = nil
    @State private var showLogoutConfirmation = false
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Settings & Privacy", backAction: { dismiss() })
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // User Profile Brief
                    VStack(spacing: 16) {
                        Image(user.profileImageURL)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            .shadow(radius: 5)
                        
                        VStack(spacing: 4) {
                            Text(user.fullName)
                                .font(AppTheme.Typography.title3)
                            Text("\(user.role) • Level \(user.level)")
                                .font(AppTheme.Typography.callout)
                                .foregroundColor(.gray)
                        }
                        
                        // Search bar 
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .font(AppTheme.Typography.subheadline)
                                .accessibilityHidden(true)
                            TextField("Search settings", text: .constant(""))
                                .font(AppTheme.Typography.callout)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // Account & Security Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "ACCOUNT & SECURITY")
                        
                    VStack(spacing: 0) {
                            NavigationLink(destination: EditProfileView()) {
                                SettingsRow(icon: "person.fill", title: "Personal Information")
                            }
                            .buttonStyle(PlainButtonStyle())
                            Divider().padding(.leading, 48)
                            SettingsRow(icon: "lock.fill", title: "Password & Security", value: "2FA, Logins, Password")
                            
                            // Face ID / Touch ID toggle — shows on any device with biometric hardware
                            if biometricService.hasBiometricHardware {
                                Divider().padding(.leading, 48)
                                SettingsRow(
                                    icon: biometricService.biometricIcon,
                                    title: "Sign in with \(biometricService.biometricType)",
                                    toggleValue: Binding(
                                        get: { biometricService.isBiometricLoginEnabled },
                                        set: { newValue in
                                            if newValue {
                                                Task {
                                                    let confirmed = await biometricService.authenticate()
                                                    if confirmed {
                                                        biometricService.isBiometricLoginEnabled = true
                                                        HapticManager.success()
                                                        toast = .success("\(biometricService.biometricType) login enabled", icon: biometricService.biometricIcon)
                                                    } else {
                                                        HapticManager.error()
                                                    }
                                                }
                                            } else {
                                                biometricService.isBiometricLoginEnabled = false
                                                biometricService.errorMessage = nil
                                                HapticManager.medium()
                                                toast = .info("\(biometricService.biometricType) login disabled", icon: biometricService.biometricIcon)
                                            }
                                        }
                                    )
                                )
                                
                                if let error = biometricService.errorMessage, !biometricService.isBiometricLoginEnabled {
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(.horizontal, 16)
                                        .padding(.bottom, 8)
                                }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    
                    // Subscription Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "SUBSCRIPTION")
                        
                        NavigationLink(destination: PremiumView()) {
                            SettingsRow(icon: "crown.fill", title: "SkillSpryng Pro", value: "PRO • Renews Dec 1")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .background(Color.white)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    
                    // Wallet Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "WALLET")
                        
                        NavigationLink(destination: WalletView()) {
                            SettingsRow(icon: "w.square.fill", title: "SkillCredits Wallet", value: "4,850 SKP")
                        }
                        .buttonStyle(PlainButtonStyle())
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
                            // Profile Visibility 
                            HStack {
                                Text("PROFILE VISIBILITY")
                                    .font(AppTheme.Typography.badge)
                                    .foregroundColor(.gray)
                                Spacer()
                                HStack(spacing: 0) {
                                    Text("Public").padding(.horizontal, 12).padding(.vertical, 6).background(AppTheme.Colors.primary).foregroundColor(.white).cornerRadius(6)
                                    Text("Private").padding(.horizontal, 12).padding(.vertical, 6).foregroundColor(.gray)
                                    Text("Mutuals").padding(.horizontal, 12).padding(.vertical, 6).foregroundColor(.gray)
                                }
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            .padding()
                            
                            Divider()
                            
                            NavigationLink(destination: ChildSafetyView()) {
                                SettingsRow(icon: "shield.lefthalf.filled", title: "Child Safety Mode", toggleValue: .constant(true))
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider().padding(.leading, 48)
                            
                            NavigationLink(destination: AddFamilyMemberView()) {
                                SettingsRow(icon: "person.badge.plus", title: "Add Family Member", toggleValue: .constant(true))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    
                    // Danger Zone
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "DANGER ZONE")
                        
                        VStack(spacing: 0) {
                            Button(action: { showDeleteConfirmation = true }) {
                                SettingsRow(icon: "trash.fill", title: "Delete Account", value: "Permanently remove all data")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    
                    // Log Out
                    Button(action: {
                        HapticManager.warning()
                        showLogoutConfirmation = true
                    }) {
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
                    .font(AppTheme.Typography.caption2)
                    .foregroundColor(.gray)
                    .padding(.bottom, 40)
                    
                    Spacer().frame(height: 60)
                }
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            biometricService.checkBiometricSupport()
            if let cachedUser = PersistenceService.shared.fetchUser() {
                self.user = cachedUser
            }
        }
        // HIG: Confirm destructive logout action with an alert
        .alert("Log Out", isPresented: $showLogoutConfirmation) {
            Button("Log Out", role: .destructive) {
                biometricService.errorMessage = nil
                PersistenceService.shared.clearCache()
                NotificationManager.shared.cancelAllPendingNotifications()
                isLoggedIn = false
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to log out of SkillSpryng?")
        }
        // HIG: Destructive delete action requires explicit confirmation
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Delete Account", role: .destructive) {
                // TODO: call delete account API
                HapticManager.error()
                toast = .error("Account deletion is not yet available.")
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete your account and all data. This action cannot be undone.")
        }
        .toast($toast)
    }
}
