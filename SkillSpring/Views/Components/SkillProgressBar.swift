// MARK: - SkillProgressBar
// Progress bar component for skill completion percentages.
import SwiftUI

struct SkillProgressBar: View {
    let name: String
    let percentage: Double
    let subheadline: String?
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(name)
                    .font(AppTheme.Typography.subheadline)
                Spacer()
                Text("\(Int(percentage))%")
                    .font(AppTheme.Typography.subheadline)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color)
                        .frame(width: geometry.size.width * (percentage / 100.0), height: 8)
                }
            }
            .frame(height: 8)
            
            if let sub = subheadline {
                Text(sub)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.gray)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(name + (subheadline != nil ? ", \(subheadline!)" : ""))
        .accessibilityValue("\(Int(percentage)) percent")
    }
}
