import SwiftUI

struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
                .tracking(1)
                .accessibilityAddTraits(.isHeader)
            
            Spacer()
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primary)
                }
                .accessibilityLabel("\(title) — \(actionTitle)")
                .accessibilityHint("Double-tap to see all")
            }
        }
    }
}
