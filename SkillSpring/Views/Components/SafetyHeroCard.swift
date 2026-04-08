import SwiftUI

struct SafetyHeroCard: View {
    let title: String
    let subtitle: String
    let isActive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .overlay(Image(systemName: "shield.fill").foregroundColor(.white))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Text(isActive ? "ACTIVE" : "INACTIVE")
                        Circle().fill(isActive ? Color.green : Color.gray).frame(width: 6, height: 6)
                    }
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.1))
                    .foregroundColor(.white)
                    .cornerRadius(4)
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Text(subtitle)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
        }
        .padding(24)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "2DBF8E"), Color(hex: "1D9E75")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(24)
        .shadow(color: Color(hex: "1D9E75").opacity(0.3), radius: 15, x: 0, y: 10)
    }
}
