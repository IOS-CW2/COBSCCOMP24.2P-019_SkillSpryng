import SwiftUI

struct OnboardingView: View {
    @State private var navigateToSignIn = false
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    HStack {
                        Spacer()
                    Button(action: { navigateToSignIn = true }) {
                        Text("Skip")
                            .foregroundColor(.gray)
                            .padding()
                    }
                    .accessibilityIdentifier("onboardingSkipButton")
                }
                
                Spacer()
                    .padding(.bottom, 40)
                    .accessibilityHidden(true)
                
                Text("Share What You Know")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.bottom, 8)
                
                Text("Give your skills to others and let your intuition create a mentor.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                }
                .padding(.bottom, 30)
                .accessibilityHidden(true)
                
                PrimaryButton(title: "Next", action: {
                    navigateToSignIn = true
                })
                .accessibilityIdentifier("onboardingNextButton")
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToSignIn) {
                SignInView()
            }
        }
    }
}
