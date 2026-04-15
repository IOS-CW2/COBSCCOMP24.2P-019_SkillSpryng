import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let subValue: String?
    let iconName: String?
    
    var body: some View {
        VStack(spacing: 8) {
            if let icon = iconName {
                Image(systemName: icon)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .accessibilityHidden(true)
            } else {
                Text(title.uppercased())
                    .font(AppTheme.Typography.badge)
                    .foregroundColor(.gray)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.black)
                
                if let sub = subValue {
                    Text(sub)
                        .font(AppTheme.Typography.badge)
                        .foregroundColor(.black)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(value)\(subValue != nil ? " \(subValue!)" : "")")
    }
}
