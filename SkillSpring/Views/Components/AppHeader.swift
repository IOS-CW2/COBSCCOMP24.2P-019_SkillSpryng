import SwiftUI

struct AppHeader: View {
    let title: String
    var showBackButton: Bool = true
    var backAction: (() -> Void)? = nil
    var actionIcon: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            if showBackButton {
                Button(action: { backAction?() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppTheme.Colors.primary)
                        .padding(8)
                        .background(Circle().fill(Color.white).shadow(color: .black.opacity(0.05), radius: 5))
                }
            }
            
            Spacer()
            
            Text(title)
                .font(AppTheme.Typography.headline)
            
            Spacer()
            
            if let actionIcon = actionIcon {
                Button(action: { action?() }) {
                    Image(systemName: actionIcon)
                        .foregroundColor(AppTheme.Colors.primary)
                        .padding(8)
                        .background(Circle().fill(Color.white).shadow(color: .black.opacity(0.05), radius: 5))
                }
            } else {
                EmptyView().frame(width: 34)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
