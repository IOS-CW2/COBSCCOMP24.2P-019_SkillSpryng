import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
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
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.8), Color.mint]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 60, height: 60)
                Image(systemName: "leaf.fill")
                    .foregroundColor(.white)
                    .font(.title2)
            }
            .padding(.top, 20)
            
            VStack(spacing: 16) {
                CustomTextField(iconName: "person", placeholder: "Full Name", text: $viewModel.fullName)
                
                CustomTextField(iconName: "phone", placeholder: "Phone number (+1234...)", text: $viewModel.phoneNumber, keyboardType: .phonePad)
                
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
            
            Button(action: { /* Face ID Placeholder */ }) {
                HStack {
                    Image(systemName: "faceid")
                        .foregroundColor(.green)
                    Text("Sign in with Face ID")
                        .foregroundColor(.green)
                        .font(.subheadline)
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.green, lineWidth: 1))
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            Text("By creating an account, you agree to \nSkillSpryng's Terms of Service and Privacy Policy.")
                .font(.caption2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
        }
        .navigationBarHidden(true)
    }
}
