import SwiftUI

struct PhoneVerificationView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 24) {
            
            // Header
            AppHeader(title: "Phone Verification", backAction: { presentationMode.wrappedValue.dismiss() })
                .padding(.top, 10)
            
            Spacer().frame(height: 40)
            
            Text("Enter 6 digit verification code sent to \nyour phone number")
                .font(.subheadline)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            OTPInputField(verificationCode: $viewModel.verificationCode)
                .padding(.horizontal, 40)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            
            PrimaryButton(title: "Verify", action: {
                viewModel.verifyCode()
            }, isLoading: viewModel.isLoading)
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            NavigationLink(destination: VerificationSuccessView(viewModel: viewModel), isActive: $viewModel.navigateToSuccess) {
                EmptyView()
            }
            
            Button(action: {
                viewModel.sendOTP()
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
    }
}
