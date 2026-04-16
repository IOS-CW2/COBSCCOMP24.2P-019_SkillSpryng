import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(title)
                .font(AppTheme.Typography.headline)
            
            Text(message)
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: action) {
                Text(actionTitle)
                    .font(AppTheme.Typography.badge)
                    .foregroundColor(AppTheme.Colors.primary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppTheme.Colors.primary.opacity(0.1))
                    .cornerRadius(20)
            }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }
}
