import SwiftUI

struct MasteryHeroCard: View {
    let data: MasteryPoints
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Outer ring
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 12)
                    .frame(width: 160, height: 160)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: CGFloat(data.progressTowardsNextLevel))
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "27E246"), Color(hex: "2DBF8E")]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("TOTAL MASTERY POINTS")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("\(data.total)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 14))
                }
            }
            .padding(.top, 20)
            
            HStack {
                Text("Level \(data.level) Curator")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(data.progressTowardsNextLevel * 100))% to Level \(data.level + 1)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)
                    Capsule()
                        .fill(Color.white)
                        .frame(width: geo.size.width * CGFloat(data.progressTowardsNextLevel), height: 6)
                }
            }
            .frame(height: 6)
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(Color(hex: "1D1D1F")) // Dark background as seen in mockup
        .cornerRadius(32)
    }
}
