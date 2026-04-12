import SwiftUI

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.surfaceLight)
                .foregroundColor(isSelected ? .white : .gray)
                .cornerRadius(20)
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .animation(.spring(), value: isSelected)
    }
}
