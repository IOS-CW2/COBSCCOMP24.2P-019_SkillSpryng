import SwiftUI

struct VerificationSuccessView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "checkmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white)
            }
            
            Text("Phone Number Verified")
                .font(.title2)
                .bold()
                .padding(.top, 16)
            
            Text("You will be redirected to the main page \nin a few moments")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            NavigationLink(destination: SkillSetupView(fullName: viewModel.fullName, phoneNumber: viewModel.phoneNumber), isActive: $viewModel.navigateToSkillSetup) {
                EmptyView()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                viewModel.navigateToSkillSetup = true
            }
        }
    }
}
