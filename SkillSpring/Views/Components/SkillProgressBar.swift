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
                    .font(.system(size: 14, weight: .bold))
                Spacer()
                Text("\(Int(percentage))%")
                    .font(.system(size: 14, weight: .bold))
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
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(name + (subheadline != nil ? ", \(subheadline!)" : ""))
        .accessibilityValue("\(Int(percentage)) percent")
    }
}
