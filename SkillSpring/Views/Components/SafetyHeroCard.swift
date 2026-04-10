import SwiftUI

struct SafetyHeroCard: View {
    let title: String
    let subtitle: String
    var isActive: Bool = true
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "1D9E75"), Color(hex: "27E246")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("ACTIVE")
                            .font(.system(size: 8, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                    
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.9))
                        .lineSpacing(4)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 80, height: 80)
                    Image(systemName: "shield.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
            }
            .padding(24)
        }
    }
}
