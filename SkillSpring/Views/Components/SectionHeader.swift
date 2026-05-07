// MARK: - SectionHeader
// Section header component with optional right-side action.
import SwiftUI

struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(AppTheme.Typography.badge)
                .foregroundColor(.gray)
                .tracking(1)
                .accessibilityAddTraits(.isHeader)
            
            Spacer()
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(AppTheme.Typography.badge)
                        .foregroundColor(AppTheme.Colors.primary)
                }
                .accessibilityLabel("\(title) — \(actionTitle)")
                .accessibilityHint("Double-tap to see all")
            }
        }
    }
}
