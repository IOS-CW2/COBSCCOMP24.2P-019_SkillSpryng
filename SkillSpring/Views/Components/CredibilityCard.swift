import SwiftUI

struct CredibilityCard: View {
    let title: String
    let score: Int
    let badge: String // e.g., "EXPERT", "PRO"
    let subheadline: String
    let iconUrl: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                Spacer()
                Text(badge)
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.primary.opacity(0.1))
                    .foregroundColor(AppTheme.Colors.primary)
                    .cornerRadius(4)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("CREDIBILITY SCORE", systemImage: "shield.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(score)%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primary)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.systemGray6))
                            .frame(height: 6)
                        Capsule()
                            .fill(AppTheme.Colors.primary)
                            .frame(width: geo.size.width * CGFloat(score) / 100, height: 6)
                    }
                }
                .frame(height: 6)
            }
            
            HStack {
                HStack(spacing: -8) {
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(Color(.systemGray4))
                            .frame(width: 24, height: 24)
                            .overlay(Image(systemName: "person.fill").font(.system(size: 10)).foregroundColor(.white))
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                    Text("+14")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.leading, 12)
                }
                
                Spacer()
                
                Button(action: { }) {
                    Text("Find Learners")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
    }
}
