import SwiftUI
import FirebaseFirestore

struct AddFamilyMemberView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var fullName = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var toast: ToastMessage? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Navigation Bar
            AppHeader(
                title: "Add Family Member",
                backAction: { presentationMode.wrappedValue.dismiss() },
                actionText: "Skip",
                action: { UserDefaults.standard.set(true, forKey: "skillspryng.isLoggedIn") }
            )
            .padding(.top, 10)
            
            // Progress Bar
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(AppTheme.Colors.primary)
                        .frame(width: geometry.size.width * 0.8) // Near the end of the setup flow
                    Rectangle()
                        .fill(Color(.systemGray6))
                        .frame(width: geometry.size.width * 0.2)
                }
            }
            .frame(height: 3)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Gradient Card with Illustration
                    ZStack(alignment: .topLeading) {
                        AppTheme.Gradients.primaryButton
                            .cornerRadius(20)
                        
                        // Background watermark graphic (simulated)
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "person.3.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 160, height: 160)
                                    .foregroundColor(Color.white.opacity(0.12))
                                    .offset(x: 30, y: 30) // Push it to bottom right
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .accessibilityHidden(true)
                        
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "shield.fill")
                                        .foregroundColor(.white)
                                    Text("Emergency Contact")
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(.white)
                                }
                                
                                Text("Add a trusted family member\nto manage skills and safety\ntogether.")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(4)
                            }
                            .accessibilityElement(children: .combine)
                            
                            Spacer()
                            
                            // Top right icon
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 45, height: 45)
                                // Using flowchart structure symbol or connected points as representation
                                Image(systemName: "point.3.connected.trianglepath.up")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                            .accessibilityHidden(true)
                        }
                        .padding(24)
                    }
                    .frame(height: 180)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    
                    // Forms Fields section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("CONTACT DETAILS")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                        
                        CustomTextField(iconName: "person", placeholder: "Full Name", text: $fullName)
                        
                        CustomTextField(iconName: "phone", placeholder: "Phone number", text: $phoneNumber, keyboardType: .phonePad)
                        
                        // Email field requires lowercased keyboard config
                        CustomTextField(iconName: "envelope", placeholder: "Email", text: $email, keyboardType: .emailAddress)
                            .autocapitalization(.none)
                    }
                    .padding(.horizontal, 24)
                    
                    Text("They'll receive an invitation link to join your\nfamily vault and access shared skills.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                    
                    // Bottom Buttons
                    VStack(spacing: 16) {
                        PrimaryButton(title: "Send Invitation", action: {
                            guard !fullName.isEmpty else { return }
                            HapticManager.success()
                            toast = .success("Invitation sent to \(fullName)!", icon: "envelope.fill")

                            // Persist the family member contact to Firestore under users/{uid}/familyMembers
                            Task {
                                if let currentUser = await FirebaseDataService.shared.fetchCurrentUser(),
                                   let uid = currentUser.id {
                                    let data: [String: Any] = [
                                        "fullName":     fullName,
                                        "phoneNumber":  phoneNumber,
                                        "email":        email,
                                        "addedAt":      Date().timeIntervalSince1970
                                    ]
                                    try? await FirebaseDataService.shared.db
                                        .collection("users").document(uid)
                                        .collection("familyMembers")
                                        .addDocument(data: data)

                                    // Write in-app notification confirming the addition
                                    await FirebaseDataService.shared.createNotification(AppNotification(
                                        type: .systemAlert,
                                        title: "Family Member Added",
                                        body: "\(fullName) has been added as an emergency contact.",
                                        referenceId: nil
                                    ))
                                }
                                // Navigate to home after brief delay so toast is visible
                                try? await Task.sleep(nanoseconds: 1_800_000_000)
                                await MainActor.run {
                                    UserDefaults.standard.set(true, forKey: "skillspryng.isLoggedIn")
                                }
                            }
                        })

                        Button(action: {
                            HapticManager.light()
                            UserDefaults.standard.set(true, forKey: "skillspryng.isLoggedIn")
                        }) {
                            Text("Skip for Now")
                                .font(.headline)
                                .foregroundColor(AppTheme.Colors.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                        .stroke(AppTheme.Colors.primary, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
        .toast($toast)
    }
}
