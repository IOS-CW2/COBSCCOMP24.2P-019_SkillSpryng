// MARK: - PlanCard
// Subscription plan card showing benefit details and pricing.
import SwiftUI

struct PlanCard: View {
    let title: String
    let price: String
    let features: [String]
    let isRecommended: Bool
    var onAction: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTheme.Typography.badge)
                        .foregroundColor(.gray)
                    Text(price)
                        .font(AppTheme.Typography.title)
                }
                Spacer()
                if isRecommended {
                    Text("BEST VALUE")
                        .font(AppTheme.Typography.badge)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(title) plan. \(price)." + (isRecommended ? " Best Value." : ""))
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(features, id: \.self) { feature in
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(isRecommended ? AppTheme.Colors.primary : .gray)
                            .accessibilityHidden(true)
                        Text(feature)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Button(action: { onAction?() }) {
                Text(isRecommended ? "Go Premium" : "Current Plan")
                    .font(AppTheme.Typography.subheadline)
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
