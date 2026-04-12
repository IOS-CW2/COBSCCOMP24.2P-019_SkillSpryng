import SwiftUI

struct OTPInputField: View {
    @Binding var verificationCode: String
    var numberOfDigits: Int = 6
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            // Visible boxes
            HStack(spacing: 12) {
                ForEach(0..<numberOfDigits, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor(at: index), lineWidth: 2)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                            .frame(width: 45, height: 55)
                        
                        Text(getDigit(at: index))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
            }
            .accessibilityHidden(true)
            
            // Hidden text field on top to capture all taps
            TextField("", text: $verificationCode)
                .keyboardType(.numberPad)
                .focused($isFocused)
                .textContentType(.oneTimeCode)
                .accentColor(.clear)
                .foregroundColor(.clear)
                .background(Color.clear)
                .accessibilityLabel("Verification Code")
                .accessibilityValue(verificationCode.isEmpty ? "Empty" : verificationCode.map { String($0) }.joined(separator: " "))
                .accessibilityHint("Enter your \(numberOfDigits)-digit code")
                .onChange(of: verificationCode) { newValue in
                    // Only allow digits
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    if filtered != newValue {
                        verificationCode = filtered
                    }
                    
                    // Limit length
                    if verificationCode.count > numberOfDigits {
                        verificationCode = String(verificationCode.prefix(numberOfDigits))
                    }
                }
        }
        .onAppear {
            isFocused = true
        }
    }
    
    private func getDigit(at index: Int) -> String {
        if index < verificationCode.count {
            let startIndex = verificationCode.index(verificationCode.startIndex, offsetBy: index)
            return String(verificationCode[startIndex])
        }
        return ""
    }
    
    private func borderColor(at index: Int) -> Color {
        if index == verificationCode.count && isFocused {
            return AppTheme.Colors.primary
        }
        if index < verificationCode.count {
            return AppTheme.Colors.primary.opacity(0.5)
        }
        return .gray.opacity(0.3)
    }
}
