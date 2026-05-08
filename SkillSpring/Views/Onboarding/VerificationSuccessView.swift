import SwiftUI

// MARK: - VerificationSuccessView
// Confirmation screen displayed after successful phone verification.
// Provides a clear success state and the next continue action into
// the age verification flow.
struct VerificationSuccessView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var calendarMessage: String?
    @State private var navigateToAge = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Success Icon matching mockup
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.primaryLight)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45, height: 45)
                    .foregroundColor(.white)
                    .bold()
            }
            .accessibilityHidden(true)
            
            VStack(spacing: 16) {
                Text("Phone Number Verified")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("You will be redirected to the main page \nin a few moments")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                
                // Three dots loading indicator
                HStack(spacing: 6) {
                    Circle().fill(AppTheme.Colors.primary).frame(width: 4, height: 4)
                    Circle().fill(AppTheme.Colors.primary).frame(width: 4, height: 4)
                    Circle().fill(AppTheme.Colors.primary).frame(width: 4, height: 4)
                }
                .padding(.top, AppTheme.Spacing.sm)
                .accessibilityHidden(true)
            }
            
            Spacer()
            
            // Bottom Action Link matching mockup
            Button(action: {
                navigateToAge = true
            }) {
                HStack(spacing: 8) {
                    Text("Continue Now")
                        .foregroundColor(AppTheme.Colors.primary)
                        .font(AppTheme.Typography.headline)
                    Image(systemName: "arrow.right")
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
            .padding(.bottom, AppTheme.Spacing.xxl)

            NavigationLink(destination: AgeVerificationView(fullName: viewModel.fullName, phoneNumber: viewModel.phoneNumber), isActive: $navigateToAge) {
                EmptyView()
            }
        }
        .navigationBarHidden(true)
    }
}
