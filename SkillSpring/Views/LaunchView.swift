import SwiftUI

struct LaunchView: View {
    @State private var isActive: Bool = false
    
    var body: some View {
        Group {
            if isActive {
                OnboardingView()
            } else {
                VStack(spacing: 20) {
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.8), Color.mint]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 80, height: 80)
                            .shadow(color: .green.opacity(0.3), radius: 10, y: 5)
                        
                        Image(systemName: "leaf.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                    }
                    
                    Text("SkillSpryng")
                        .font(.system(size: 32, weight: .bold, design: .default))
                        .foregroundColor(.black)
                    
                    Text("Teach. Learn. Grow.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Circle().fill(Color.green).frame(width: 6, height: 6)
                        Circle().fill(Color.green.opacity(0.5)).frame(width: 6, height: 6)
                        Circle().fill(Color.green.opacity(0.3)).frame(width: 6, height: 6)
                    }
                    .padding(.bottom, 40)
                }
                .navigationBarHidden(true)
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
