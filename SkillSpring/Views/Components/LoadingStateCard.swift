import SwiftUI

// MARK: - LoadingStateCard
/// A card that displays a loading spinner with a message.
/// Used in views to show that data is being fetched or synced.
struct LoadingStateCard: View {
    let message: String
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Loading spinner
                ProgressView()
                    .tint(AppTheme.Colors.primary)
                
                Text(message)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(AppTheme.Colors.primary.opacity(0.05))
            .cornerRadius(10)
        }
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loading: \(message)")
    }
}

#Preview {
    LoadingStateCard(message: "Updating profile...")
}
