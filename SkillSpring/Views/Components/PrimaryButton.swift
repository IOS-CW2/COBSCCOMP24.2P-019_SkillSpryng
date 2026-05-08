// MARK: - PrimaryButton
// Primary action button used across the app for CTA actions.
import SwiftUI

/// Primary call-to-action button.
/// Uses the app-wide gradient from `AppTheme.Gradients.primaryButton`.
struct PrimaryButton: View {
    var title: String
    var action: () -> Void
    var isLoading: Bool = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .fill(AppTheme.Colors.primary)
                    .frame(height: 56)
                    
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .disabled(isLoading)
        .accessibilityButton(label: title, hint: "Double-tap to \(title.lowercased())")
        .accessibilityValue(isLoading ? "Loading" : "")
    }
}
