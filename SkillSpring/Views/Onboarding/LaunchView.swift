import SwiftUI

struct LaunchView: View {
    @State private var isActive: Bool = false
    @State private var activeDotIndex: Int = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        Group {
            if isActive {
                OnboardingView()
            } else {
                ZStack {
                    Color.white.ignoresSafeArea()
                    VStack(spacing: 20) {
                        Spacer()

                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .shadow(color: AppTheme.Colors.primary.opacity(0.2), radius: 15, y: 8)
                            .accessibilityHidden(true)

                        Text("SkillSpryng")
                            .font(AppTheme.Typography.displayTitle)
                            .foregroundColor(AppTheme.Colors.textPrimary)

                        Text("Teach. Learn. Grow.")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.textSecondary)

                        Spacer()

                        HStack(spacing: 8) {
                            ForEach(0..<3) { index in
                                Circle()
                                    .fill(AppTheme.Colors.primary.opacity(activeDotIndex == index ? 1.0 : 0.2))
                                    .frame(width: activeDotIndex == index ? 8 : 6, height: activeDotIndex == index ? 8 : 6)
                            }
                        }
                        .padding(.bottom, 48)
                        .accessibilityHidden(true)
                        .onAppear {
                            guard !reduceMotion else { return }
                            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    activeDotIndex = (activeDotIndex + 1) % 3
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if reduceMotion {
                    self.isActive = true
                } else {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}
