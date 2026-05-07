// MARK: - AppHeader
// Consistent screen header with optional back and action buttons.
import SwiftUI

struct AppHeader: View {
    let title: String
    var showBackButton: Bool = true
    var backAction: (() -> Void)? = nil
    var actionIcon: String? = nil
    var actionText: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            // Absolute Center Title
            Text(title)
                .font(AppTheme.Typography.headline)
                .multilineTextAlignment(.center)
            
            // Side Actions
            HStack {
                if showBackButton, let backAction = backAction {
                    Button(action: backAction) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(AppTheme.Colors.primary)
                            .padding(8)
                            .background(Circle().fill(Color.white).shadow(color: .black.opacity(0.05), radius: 5))
                    }
                }
                
                Spacer()
                
                if let actionIcon = actionIcon {
                    Button(action: { action?() }) {
                        Image(systemName: actionIcon)
                            .foregroundColor(AppTheme.Colors.primary)
                            .padding(8)
                            .background(Circle().fill(Color.white).shadow(color: .black.opacity(0.05), radius: 5))
                    }
                } else if let actionText = actionText {
                    Button(action: { action?() }) {
                        Text(actionText)
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.primary)
                            .padding(8)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
