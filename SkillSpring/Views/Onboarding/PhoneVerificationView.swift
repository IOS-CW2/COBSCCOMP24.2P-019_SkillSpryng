import SwiftUI

// MARK: - PhoneVerificationView
// OTP verification screen for users who are signing in with phone authentication.
// Shows the code entry fields, verification button, resend action, and
// navigation to the success confirmation view when verification completes.
struct PhoneVerificationView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var toast: ToastMessage? = nil
    
    var body: some View {
        VStack(spacing: 24) {
            
            // Header
            // Provides a back button and title for the OTP verification flow.
            AppHeader(title: "Phone Verification", backAction: { presentationMode.wrappedValue.dismiss() })
                .padding(.top, 10)
            
            Spacer().frame(height: 40)
            
            Text("Enter 6 digit verification code sent to \nyour phone number")
                .font(.subheadline)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            OTPInputField(verificationCode: $viewModel.verificationCode, accessibilityIdentifier: "otpInputField")
                .padding(.horizontal, 40)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            
            // Verification action
            PrimaryButton(title: "Verify", action: {
                HapticManager.light()
                viewModel.verifyCode()
            }, isLoading: viewModel.isLoading)
            .accessibilityIdentifier("verifyOTPButton")
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            NavigationLink(destination: VerificationSuccessView(viewModel: viewModel), isActive: $viewModel.navigateToSuccess) {
                EmptyView()
            }
            
            Button(action: {
                HapticManager.light()
                viewModel.sendOTP()
                toast = .info("Verification code resent", icon: "envelope.fill")
            }) {
                Text("Resend Code")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.Colors.primary)
                    .bold()
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .navigationBarHidden(true)
        .toast($toast)
    }
}
