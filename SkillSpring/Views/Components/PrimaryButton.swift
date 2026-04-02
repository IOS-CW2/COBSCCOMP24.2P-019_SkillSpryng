import SwiftUI

struct PrimaryButton: View {
    var title: String
    var action: () -> Void
    var isLoading: Bool = false
    var backgroundColor: Color = Color.green
    
    let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [Color(red: 0.1, green: 0.8, blue: 0.4), Color(red: 0.0, green: 0.5, blue: 0.9)]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundGradient)
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
    }
}
