import SwiftUI

struct LaunchView: View {
    @State private var isActive: Bool = false
    
    var body: some View {
        Group {
            if isActive {
                OnboardingView()
            } else {
                ZStack {
                    Color.white.ignoresSafeArea()
                    VStack(spacing: 20) {
                        Spacer()

                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(AppTheme.Gradients.onboarding)
                                .frame(width: 90, height: 90)
                                .shadow(color: AppTheme.Colors.primary.opacity(0.3), radius: 12, y: 6)

                            Image(systemName: "leaf.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 44, height: 44)
                                .foregroundColor(.white)
                        }

                        Text("SkillSpryng")
                            .font(.system(size: 34, weight: .bold, design: .default))
                            .foregroundColor(AppTheme.Colors.textPrimary)

                        Text("Teach. Learn. Grow.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(AppTheme.Colors.textSecondary)

                        Spacer()

                        HStack(spacing: 8) {
                            Circle().fill(AppTheme.Colors.primary).frame(width: 8, height: 8)
                            Circle().fill(AppTheme.Colors.primary.opacity(0.35)).frame(width: 6, height: 6)
                            Circle().fill(AppTheme.Colors.primary.opacity(0.2)).frame(width: 6, height: 6)
                        }
                        .padding(.bottom, 48)
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
}
