import SwiftUI
import Combine

struct OnboardingStep: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    let description: String
}

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var navigateToSignIn = false
    
    let steps = [
        OnboardingStep(image: "onboard1", title: "Share What You Know", description: "Offer your skills to others and build your reputation as a mentor."),
        OnboardingStep(image: "onboard2", title: "Learn From Experts", description: "Access a wide range of skills taught by passionate community members."),
        OnboardingStep(image: "onboard3", title: "Build Your Network", description: "Connect with like-minded individuals and grow your professional circle."),
        OnboardingStep(image: "onboard4", title: "Grow Your Skills", description: "Track your progress and earn rewards as you master new disciplines.")
    ]
    
    @State private var scrollTimer: Timer?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Spacer()
                        Button(action: { navigateToSignIn = true }) {
                            Text("Skip")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                        }
                        .accessibilityIdentifier("onboardingSkipButton")
                    }
                    .padding(.top, 10)
                    
                    // Carousel
                    TabView(selection: $currentPage) {
                        ForEach(0..<steps.count, id: \.self) { index in
                            OnboardingPage(step: steps[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .onAppear {
                        scrollTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
                            if currentPage < steps.count - 1 {
                                withAnimation {
                                    currentPage += 1
                                }
                            }
                        }
                    }
                    .onDisappear {
                        scrollTimer?.invalidate()
                    }
                    .animation(.easeInOut, value: currentPage)
                    
                    // Page Indicator & Footer
                    VStack(spacing: 32) {
                        // Custom Pill Indicators
                        HStack(spacing: 8) {
                            ForEach(0..<steps.count, id: \.self) { index in
                                Capsule()
                                    .fill(currentPage == index ? AppTheme.Colors.primary : Color.gray.opacity(0.2))
                                    .frame(width: currentPage == index ? 24 : 8, height: 8)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                            }
                        }
                        
                        // Action Button
                        PrimaryButton(
                            title: currentPage == steps.count - 1 ? "Get Started" : "Next",
                            action: {
                                if currentPage < steps.count - 1 {
                                    withAnimation {
                                        currentPage += 1
                                    }
                                } else {
                                    navigateToSignIn = true
                                }
                            }
                        )
                        .accessibilityIdentifier("onboardingNextButton")
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToSignIn) {
                SignInView()
            }
        }
    }
}

struct OnboardingPage: View {
    let step: OnboardingStep
    
    var body: some View {
        VStack(spacing: 40) {
            // Illustration Container
            ZStack {
                RoundedRectangle(cornerRadius: 32)
                    .fill(AppTheme.Gradients.heroCard)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1.0, contentMode: .fit)
                    .padding(.horizontal, 24)
                
                Image(step.image)
                    .resizable()
                    .scaledToFit()
                    .padding(48)
            }
            
            // Text Content
            VStack(spacing: 16) {
                Text(step.title)
                    .font(AppTheme.Typography.displayTitle)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(step.description)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineSpacing(4)
            }
            
            Spacer()
        }
        .padding(.top, 20)
    }
}

#Preview {
    OnboardingView()
}
