import SwiftUI

struct StatusBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text.uppercased())
            .font(AppTheme.Typography.badge)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(4)
            .accessibilityLabel("Status: \(text)")
    }
}

// Convenience extension for semantic states
extension StatusBadge {
    static func sessionStatus(_ status: SessionStatus) -> some View {
        let color: Color
        switch status {
        case .upcoming: color = Color.blue
        case .completed: color = Color.gray
        case .cancelled: color = Color.red
        }
        return StatusBadge(text: status.rawValue, color: color)
    }
}
