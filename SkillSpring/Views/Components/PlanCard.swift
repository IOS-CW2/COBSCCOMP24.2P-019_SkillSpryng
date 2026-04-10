import SwiftUI

struct PlanCard: View {
    let title: String
    let price: String
    let features: [String]
    let isRecommended: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    Text(price)
                        .font(.system(size: 28, weight: .bold))
                }
                Spacer()
                if isRecommended {
                    Text("BEST VALUE")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(features, id: \.self) { feature in
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(isRecommended ? AppTheme.Colors.primary : .gray)
                        Text(feature)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Button(action: { }) {
                Text(isRecommended ? "Go Premium" : "Current Plan")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isRecommended ? .white : AppTheme.Colors.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isRecommended ? AppTheme.Colors.primary : Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppTheme.Colors.primary, lineWidth: isRecommended ? 0 : 1)
                    )
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(isRecommended ? AppTheme.Colors.primary : Color.clear, lineWidth: 2)
        )
    }
}
