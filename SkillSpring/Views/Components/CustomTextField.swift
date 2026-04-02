import SwiftUI

struct CustomTextField: View {
    var iconName: String
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.gray)
                .frame(width: 24)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .foregroundColor(.black)
                .font(.body)
                .accessibilityLabel(placeholder)
                .accessibilityValue(text)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Enter your \(placeholder)")
    }
}
