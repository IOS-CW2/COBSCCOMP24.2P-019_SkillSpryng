import SwiftUI

struct SettingsRow: View {
    let icon: String
    let title: String
    var value: String? = nil
    var showToggle: Bool = false
    @Binding var toggleValue: Bool
    
    // Initializer for regular row
    init(icon: String, title: String, value: String? = nil) {
        self.icon = icon
        self.title = title
        self.value = value
        self.showToggle = false
        self._toggleValue = .constant(false)
    }
    
    // Initializer for toggle row
    init(icon: String, title: String, toggleValue: Binding<Bool>) {
        self.icon = icon
        self.title = title
        self.value = nil
        self.showToggle = true
        self._toggleValue = toggleValue
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 32, height: 32)
                .background(AppTheme.Colors.primary.opacity(0.1))
                .cornerRadius(8)
                .accessibilityHidden(true)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
            
            Spacer()
            
            if showToggle {
                Toggle("", isOn: $toggleValue)
                    .tint(AppTheme.Colors.primary)
            } else {
                if let value = value {
                    Text(value)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primary)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .accessibilityElement(children: showToggle ? .contain : .combine)
        .accessibilityLabel(showToggle ? "" : (title + (value != nil ? ", \(value!)" : "")))
        .accessibilityAddTraits(showToggle ? [] : .isButton)
    }
}
