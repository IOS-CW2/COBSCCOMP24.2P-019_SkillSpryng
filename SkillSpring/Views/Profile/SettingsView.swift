import SwiftUI

// MARK: - SettingsView
// User account settings hub.
// Offers controls for profile, security, subscription, wallet,
// preferences, privacy, and destructive actions like logout.
struct SettingsView: View {
    @StateObject private var vm = ProfileViewModel()
    @AppStorage("skillspryng.pushNotifications") private var pushNotifications = true
    @AppStorage("skillspryng.darkMode") private var darkMode = false
    @AppStorage("skillspryng.profileVisibility") private var profileVisibility = "Public"
    @ObservedObject private var biometricService = BiometricAuthService.shared
    @AppStorage("skillspryng.isLoggedIn") private var isLoggedIn = false
    @Environment(\.dismiss) var dismiss
    @State private var isDeletingAccount = false

    // Search — real binding instead of .constant("")
    @State private var settingsSearch: String = ""

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
                        // WCAG 1.1.1: non-decorative image must have a text alternative
                        SmartAvatar(imageUrl: vm.user.profileImageURL, width: 80, height: 80)
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        
                        .shadow(radius: 5)
                        .accessibilityLabel("Profile photo of \(vm.user.fullName)")
                        
                        VStack(spacing: 4) {
                            Text(vm.user.fullName)
                                .font(AppTheme.Typography.title3)
                            Text("\(vm.user.role) • Level \(vm.user.level)")
                                .font(AppTheme.Typography.callout)
                                .foregroundColor(.gray)
                        }
                        
                        // Search bar — WCAG 1.3.1 / 4.1.2: label must be programmatically determinable
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .font(AppTheme.Typography.subheadline)
                                .accessibilityHidden(true)
                            TextField("Search settings", text: $settingsSearch)
                                .font(AppTheme.Typography.callout)
                                .accessibilityLabel("Search settings")
                                .accessibilityHint("Type to filter settings options")
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
                            // Enables a secure biometric sign-in path once confirmed.
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
                            // Live wallet balance from Firestore via ProfileViewModel
                            SettingsRow(icon: "w.square.fill", title: "SkillCredits Wallet",
                                        value: vm.isLoading ? "—" : "\(vm.user.walletBalance) SKP")
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
                            HStack(alignment: .center, spacing: 12) {
                                Text("PROFILE VISIBILITY")
                                    .font(AppTheme.Typography.badge)
                                    .foregroundColor(.gray)
                                Spacer()
                                HStack(spacing: 8) {
                                    ForEach(["Public", "Private", "Mutuals"], id: \.self) { option in
                                        Button(action: {
                                            profileVisibility = option
                                            Task { await vm.updateProfileVisibility(option) }
                                        }) {
                                            Text(option)
                                                .font(AppTheme.Typography.subheadline)
                                                .foregroundColor(profileVisibility == option ? .white : .gray)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.75)
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 10)
                                                .frame(minWidth: 72)
                                                .background(profileVisibility == option ? AppTheme.Colors.primary : Color(.systemGray6))
                                                .clipShape(Capsule())
                                        }
                                        .accessibilityAddTraits(profileVisibility == option ? .isSelected : [])
                                    }
                                }
                                .padding(6)
                                .background(Color(.systemGray6))
                                .cornerRadius(20)
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 20)
                            
                            Divider()
                            
                            NavigationLink(destination: ChildSafetyView()) {
                                SettingsRow(icon: "shield.lefthalf.filled", title: "Child Safety Mode")
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider().padding(.leading, 48)
                            
                            NavigationLink(destination: AddFamilyMemberView()) {
                                SettingsRow(icon: "person.badge.plus", title: "Add Family Member")
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
                        // This section includes irreversible account actions.
                        // This section includes irreversible actions and should be used with care.
                        
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
                self.vm.user = cachedUser
            }
        }
        // HIG: Confirm destructive logout action with an alert
        .alert("Log Out", isPresented: $showLogoutConfirmation) {
            Button("Log Out", role: .destructive) {
                biometricService.errorMessage = nil
                if biometricService.isBiometricLoginEnabled {
                    // Preserve Firebase auth session for biometric re-login.
                    PersistenceService.shared.clearCache()
                    PersistenceService.shared.clearSessionCache()
                    NotificationManager.shared.cancelAllPendingNotifications()
                    isLoggedIn = false
                } else {
                    try? FirebaseManager.shared.signOut()
                    PersistenceService.shared.clearCache()
                    PersistenceService.shared.clearSessionCache()
                    NotificationManager.shared.cancelAllPendingNotifications()
                    isLoggedIn = false
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to log out of SkillSpryng?")
        }
        // HIG: Destructive delete action requires explicit confirmation
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Delete Account", role: .destructive) {
                HapticManager.error()
                isDeletingAccount = true
                Task {
                    await vm.deleteAccount()
                    isDeletingAccount = false
                    isLoggedIn = false
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete your account and all data. This action cannot be undone.")
        }
        .toast($toast)
    }
}
