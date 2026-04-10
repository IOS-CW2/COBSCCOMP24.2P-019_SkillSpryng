import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                
                // Header
                AppHeader(title: "Get Started", backAction: { presentationMode.wrappedValue.dismiss() })
                    .padding(.top, 10)
                
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                        .fill(AppTheme.Gradients.onboarding)
                        .frame(width: 60, height: 60)
                    Image(systemName: "leaf.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                }
                .padding(.top, AppTheme.Spacing.lg)
                
                VStack(spacing: 16) {
                    CustomTextField(iconName: "person", placeholder: "Full Name", text: $viewModel.fullName)
                    
                    CustomTextField(iconName: "phone", placeholder: "Phone number (+1234...)", text: $viewModel.phoneNumber, keyboardType: .phonePad)
                        .textContentType(.telephoneNumber)
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    
                    PrimaryButton(title: "Send OTP", action: {
                        viewModel.sendOTP()
                    }, isLoading: viewModel.isLoading)
                    .padding(.top, 10)
                }
                .padding(.horizontal, 24)
                
                NavigationLink(destination: PhoneVerificationView(viewModel: viewModel), isActive: $viewModel.navigateToOTP) {
                    EmptyView()
                }
                
                HStack {
                    Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
                    Text("OR CONTINUE WITH")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                    Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
                
                VStack(spacing: 16) {
                    Button(action: { /* Apple Auth Placeholder */ }) {
                        HStack {
                            Image(systemName: "applelogo")
                                .foregroundColor(.white)
                                .font(.title3)
                            Text("Continue with Apple")
                                .foregroundColor(.white)
                                .font(AppTheme.Typography.subheadline)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
                        .cornerRadius(AppTheme.Radius.md)
                    }
                    
                    Button(action: { /* Google Auth Placeholder */ }) {
                        HStack {
                            Text("G")
                                .foregroundColor(.blue)
                                .font(.title3)
                                .bold()
                            Text("Continue with Google")
                                .foregroundColor(.primary)
                                .font(AppTheme.Typography.subheadline)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: AppTheme.Radius.md).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }
                    
                    Button(action: { 
                        viewModel.authenticateWithBiometrics() 
                    }) {
                        HStack {
                            Image(systemName: "faceid")
                                .foregroundColor(AppTheme.Colors.primary)
                            Text("Sign in with Face ID")
                                .foregroundColor(AppTheme.Colors.primary)
                                .font(AppTheme.Typography.subheadline)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: AppTheme.Radius.md).stroke(AppTheme.Colors.primary, lineWidth: 1))
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                
                // Navigate to success if biometrics pass
                NavigationLink(destination: VerificationSuccessView(viewModel: viewModel), isActive: $viewModel.navigateToSuccess) {
                    EmptyView()
                }
                
                Spacer().frame(height: 20)
                
                Text("By creating an account, you agree to \nSkillSpryng's Terms of Service and Privacy Policy.")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
    }
}
