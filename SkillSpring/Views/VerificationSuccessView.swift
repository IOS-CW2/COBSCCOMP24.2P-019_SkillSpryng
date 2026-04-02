import SwiftUI

struct VerificationSuccessView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var calendarMessage: String?
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Success Icon matching mockup
            ZStack {
                Circle()
                    .fill(Color(hex: "3AC45A")) // Emerald Green from mockup
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45, height: 45)
                    .foregroundColor(.white)
                    .bold()
            }
            
            VStack(spacing: 16) {
                Text("Phone Number Verified")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("You will be redirected to the main page \nin a few moments")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                
                // Three dots indicator matching mockup
                HStack(spacing: 6) {
                    Circle().fill(Color(hex: "00A86B")).frame(width: 4, height: 4)
                    Circle().fill(Color(hex: "00A86B")).frame(width: 4, height: 4)
                    Circle().fill(Color(hex: "00A86B")).frame(width: 4, height: 4)
                }
                .padding(.top, 10)
            }
            
            Spacer()
            
            // Bottom Action Link matching mockup
            Button(action: {
                viewModel.navigateToSkillSetup = true
            }) {
                HStack(spacing: 8) {
                    Text("Continue Now")
                        .foregroundColor(Color(hex: "3AC45A"))
                        .font(.headline)
                    Image(systemName: "arrow.right")
                        .foregroundColor(Color(hex: "3AC45A"))
                }
            }
            .padding(.bottom, 40)
            
            NavigationLink(destination: SkillSetupView(fullName: viewModel.fullName, phoneNumber: viewModel.phoneNumber), isActive: $viewModel.navigateToSkillSetup) {
                EmptyView()
            }
        }
        .navigationBarHidden(true)
    }
}
