import SwiftUI

struct EditProfileView: View {
    @StateObject private var vm = ProfileViewModel()
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
                            Image(vm.user.profileImageURL)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .shadow(color: Color.black.opacity(0.1), radius: 10)
                            
                            Button(action: { }) {
                                Image(systemName: "camera.fill")
                                    .font(AppTheme.Typography.subheadline)
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
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                    .padding(.top, 20)
                    
                    // Form Fields
                    VStack(alignment: .leading, spacing: 24) {
                        EditField(label: "FULL NAME", text: $vm.user.fullName)
                        EditField(label: "PHONE NUMBER", text: $vm.user.phoneNumber)
                        EditField(label: "LOCATION", text: $vm.user.location)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("BIO")
                                .font(AppTheme.Typography.badge)
                                .foregroundColor(.gray)
                            
                            TextEditor(text: $vm.user.bio)
                                .font(AppTheme.Typography.callout)
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
                            .font(AppTheme.Typography.headline)
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
                            .font(AppTheme.Typography.subheadline)
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
                .font(AppTheme.Typography.badge)
                .foregroundColor(.gray)
            
            TextField("", text: $text)
                .font(AppTheme.Typography.callout)
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
