import SwiftUI

struct PodiumMember: View {
    let rank: Int
    let name: String
    let points: Int
    let avatar: String
    let role: String
    var isLarge: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottom) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: isLarge ? 100 : 75, height: isLarge ? 100 : 75)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    Image(avatar)
                        .resizable()
                        .scaledToFill()
                        .frame(width: isLarge ? 90 : 65, height: isLarge ? 90 : 65)
                        .clipShape(Circle())
                        .accessibilityHidden(true)
                }
                
                ZStack {
                    Circle()
                        .fill(rank == 1 ? Color.yellow : (rank == 2 ? Color.gray.opacity(0.8) : Color.orange.opacity(0.8)))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Text("\(rank)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
                .offset(y: 12)
            }
            .padding(.bottom, 8)
            
            VStack(spacing: 2) {
                Text(name)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("\(points.formatted())")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primary)
            }
            
            if isLarge {
                Text(role)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Rank \(rank). \(name). \(points) points." + (isLarge ? " \(role)" : ""))
    }
}
