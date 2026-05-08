// MARK: - SkillBadge
// Styled badge for skill labels, learning categories, and info tags.
import SwiftUI

struct SkillBadge: View {
    let title: String
    let color: Color
    let textColor: Color
    let icon: String?
    
    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(AppTheme.Typography.caption2)
                    .accessibilityHidden(true)
            }
            Text(title.uppercased())
                .font(AppTheme.Typography.badge)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color)
        .foregroundColor(textColor)
        .cornerRadius(8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isStaticText)
    }
}

extension SkillBadge {
    static func teaching(_ title: String) -> SkillBadge {
        SkillBadge(title: title, color: AppTheme.Colors.primary.opacity(0.1), textColor: AppTheme.Colors.primary, icon: "text.book.closed.fill")
    }
    
    static func learning(_ title: String) -> SkillBadge {
        SkillBadge(title: title, color: AppTheme.Colors.info.opacity(0.1), textColor: AppTheme.Colors.info, icon: "graduationcap.fill")
    }
    
    static func info(_ title: String, icon: String) -> SkillBadge {
        SkillBadge(title: title, color: AppTheme.Colors.primary.opacity(0.1), textColor: AppTheme.Colors.primary, icon: icon)
    }
}
