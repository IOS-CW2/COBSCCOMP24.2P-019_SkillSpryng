import SwiftUI

struct MilestoneRow: View {
    let milestone: Milestone
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(width: 44, height: 44)
                Image(systemName: milestone.iconName)
                    .foregroundColor(.orange)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(milestone.title)
                    .font(AppTheme.Typography.subheadline)
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.systemGray6))
                            .frame(height: 4)
                        Capsule()
                            .fill(AppTheme.Colors.primary)
                            .frame(width: geo.size.width * CGFloat(milestone.progress) / CGFloat(milestone.total), height: 4)
                    }
                }
                .frame(height: 4)
            }
            
            Text("\(milestone.progress)/\(milestone.total)")
                .font(AppTheme.Typography.badge)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(milestone.title). Progress: \(milestone.progress) out of \(milestone.total)")
    }
}
