import SwiftUI

struct OnboardingView: View {
    @State private var navigateToSignIn = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    NavigationLink(destination: SignInView(), isActive: $navigateToSignIn) {
                        Text("Skip")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 24)
                    .fill(AppTheme.Colors.primary.opacity(0.07))
                    .frame(width: 280, height: 280)
                    .overlay(
                        VStack {
                            Image(systemName: "person.3.sequence.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .foregroundColor(AppTheme.Colors.primary.opacity(0.75))
                        }
                    )
                    .padding(.bottom, 40)
                
                Text("Share What You Know")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.bottom, 8)
                
                Text("Give your skills to others and let your intuition create a mentor.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.Colors.primary)
                        .frame(width: 24, height: 6)
                    Circle().fill(AppTheme.Colors.primary.opacity(0.25)).frame(width: 6, height: 6)
                }
                .padding(.bottom, 30)
                
                PrimaryButton(title: "Next", action: {
                    navigateToSignIn = true
                })
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }
}
