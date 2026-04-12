import SwiftUI

struct ParentalSetupView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var parentName = ""
    @State private var parentEmail = ""
    @State private var navigateToSkillSetup = false
    
    var body: some View {
        ZStack {
            // Light background behind the card
            AppTheme.Colors.surfaceLight
                .edgesIgnoringSafeArea(.all)
                
            VStack(spacing: 0) {
                // Top Navigation Bar
                AppHeader(title: "Parental Setup", backAction: { presentationMode.wrappedValue.dismiss() })
                    .background(Color.white)
                
                // Progress Bar
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(AppTheme.Colors.primary)
                            .frame(width: geometry.size.width * 0.5)
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: geometry.size.width * 0.5)
                    }
                }
                .frame(height: 2)
                .background(AppTheme.Colors.primary.opacity(0.2))
                
                ScrollView(showsIndicators: false) {
                    VStack {
                        VStack(spacing: 24) {
                            
                            // Circular Person Icon
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.94, green: 0.96, blue: 0.95))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(Color(red: 0.05, green: 0.45, blue: 0.35))
                            }
                            .padding(.top, 30)
                            .accessibilityHidden(true)
                            
                            Text("A parent or guardian needs to\nset up your account")
                                .font(.title3)
                                .bold()
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Text("Ask a parent to enter their details\nbelow to approve your account.")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Parent / Guardian Full Name")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.gray)
                                
                                TextField("Enter name", text: $parentName)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(AppTheme.Radius.md)
                                    .accessibilityLabel("Parent or Guardian Full Name")
                            }
                            .padding(.horizontal, 24)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Parent / Guardian Email")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.gray)
                                
                                TextField("email@example.com", text: $parentEmail)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(AppTheme.Radius.md)
                                    .accessibilityLabel("Parent or Guardian Email")
                            }
                            .padding(.horizontal, 24)
                            
                            Spacer(minLength: 16)
                            
                            Button(action: {
                                navigateToSkillSetup = true
                            }) {
                                HStack {
                                    Text("Send Approval Request")
                                        .font(.headline)
                                    Image(systemName: "paperplane")
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(AppTheme.Gradients.primaryButton)
                                .cornerRadius(AppTheme.Radius.md)
                            }
                            .padding(.horizontal, 24)

                            NavigationLink(
                                destination: SkillSetupView(fullName: "", phoneNumber: ""),
                                isActive: $navigateToSkillSetup
                            ) { EmptyView() }
                            
                            Text("Your parent will receive an email to review and\napprove your account before you can use\nSkillSpryng.")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .padding(.bottom, 30)
                        }
                        .background(Color.white)
                        .cornerRadius(24)
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                        
                        // Drop Shadow below card
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        
                        Spacer()
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}
