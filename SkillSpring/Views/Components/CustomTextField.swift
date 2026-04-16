import SwiftUI

struct CustomTextField: View {
    var iconName: String
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var accessibilityIdentifier: String? = nil
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(isFocused ? AppTheme.Colors.primary : AppTheme.Colors.textSecondary)
                .frame(width: 24)
                .accessibilityHidden(true)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .focused($isFocused)
                .textInputAutocapitalization(.none)
                .autocorrectionDisabled()
                .foregroundColor(.black)
                .font(.body)
                .accessibilityLabel(placeholder)
                .accessibilityValue(text)
                .accessibilityIdentifier(accessibilityIdentifier ?? "")
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                .stroke(isFocused ? AppTheme.Colors.primary.opacity(0.5) : Color.clear, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = true
        }
    }
}
