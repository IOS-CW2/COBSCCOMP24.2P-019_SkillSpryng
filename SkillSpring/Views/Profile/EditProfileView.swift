import SwiftUI

struct EditProfileView: View {
    @State private var user = MockDataProvider.shared.currentUser
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            AppHeader(title: "Edit Profile", backAction: { dismiss() })
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Avatar Header
                    VStack(spacing: 16) {
                        ZStack(alignment: .bottomTrailing) {
                            Image(user.profileImageURL)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .shadow(color: Color.black.opacity(0.1), radius: 10)
                            
                            Button(action: { }) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 36, height: 36)
                                    .background(AppTheme.Colors.primary)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            }
                            .accessibilityLabel("Update profile photo")
                            .offset(x: 4, y: 4)
                        }
                        
                        Text("Change Profile Photo")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                    .padding(.top, 20)
                    
                    // Form Fields
                    VStack(alignment: .leading, spacing: 24) {
                        EditField(label: "FULL NAME", text: $user.fullName)
                        EditField(label: "PHONE NUMBER", text: $user.phoneNumber)
                        EditField(label: "LOCATION", text: $user.location)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("BIO")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.gray)
                            
                            TextEditor(text: $user.bio)
                                .font(.system(size: 14))
                                .padding(12)
                                .frame(height: 100)
                                .background(Color(.systemGray6).opacity(0.5))
                                .cornerRadius(12)
                                .accessibilityLabel("Bio")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Save Button
                    Button(action: { dismiss() }) {
                        Text("Save Changes")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.Colors.primary)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    .padding(.top, 24)
                    
                    // Dangerous Zone
                    Button(action: { }) {
                        Text("Delete Account")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.red)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct EditField: View {
    let label: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
            
            TextField("", text: $text)
                .font(.system(size: 16, weight: .medium))
                .padding()
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(12)
                .accessibilityLabel(label)
        }
    }
}

#Preview {
    EditProfileView()
}
