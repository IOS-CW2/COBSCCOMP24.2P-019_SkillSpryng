import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.green)
                            .padding()
                    }
                    Spacer()
                    Text("Create Account")
                        .font(.headline)
                        .bold()
                    Spacer()
                    Image(systemName: "chevron.left").opacity(0).padding()
                }
                
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
                
                HStack(spacing: 20) {
                    Button(action: { /* Google Auth Placeholder */ }) {
                        Circle()
                            .fill(Color(.systemGray6))
                            .frame(width: 50, height: 50)
                            .overlay(Image(systemName: "g.circle.fill").foregroundColor(.red).font(.title2))
                    }
                    
                    Button(action: { /* Apple Auth Placeholder */ }) {
                        Circle()
                            .fill(Color(.systemGray6))
                            .frame(width: 50, height: 50)
                            .overlay(Image(systemName: "applelogo").foregroundColor(.black).font(.title3))
                    }
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
                    .overlay(RoundedRectangle(cornerRadius: AppTheme.Radius.md).stroke(AppTheme.Colors.primary, lineWidth: 1))
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
