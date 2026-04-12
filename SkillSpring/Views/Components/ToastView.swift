import SwiftUI

// MARK: - Toast Model

/// Represents a single toast notification.
/// Per Apple HIG: non-blocking feedback for brief confirmations.
struct ToastMessage: Equatable {
    let message: String
    let icon: String
    let style: ToastStyle
    
    enum ToastStyle: Equatable {
        case success
        case error
        case warning
        case info
        
        var iconColor: Color {
            switch self {
            case .success: return Color.green
            case .error:   return Color.red
            case .warning: return Color.orange
            case .info:    return AppTheme.Colors.primary
            }
        }
        
        /// Default icon if none provided
        var defaultIcon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error:   return "xmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .info:    return "info.circle.fill"
            }
        }
    }
    
    // MARK: - Convenience initialisers
    
    static func success(_ message: String, icon: String = "checkmark.circle.fill") -> ToastMessage {
        ToastMessage(message: message, icon: icon, style: .success)
    }
    
    static func error(_ message: String, icon: String = "xmark.circle.fill") -> ToastMessage {
        ToastMessage(message: message, icon: icon, style: .error)
    }
    
    static func warning(_ message: String, icon: String = "exclamationmark.triangle.fill") -> ToastMessage {
        ToastMessage(message: message, icon: icon, style: .warning)
    }
    
    static func info(_ message: String, icon: String = "info.circle.fill") -> ToastMessage {
        ToastMessage(message: message, icon: icon, style: .info)
    }
}

// MARK: - Toast View

/// A floating pill-style banner that auto-dismisses.
/// Follows Apple HIG: brief, clear, non-blocking, appears near content it relates to.
struct ToastView: View {
    let toast: ToastMessage
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: toast.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(toast.style.iconColor)
            
            Text(toast.message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(2)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 13)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(toast.style == .error ? "Error: " : (toast.style == .warning ? "Warning: " : ""))\(toast.message)")
        .accessibilityAddTraits(.isStaticText)
    }
}

// MARK: - Toast View Modifier

/// Overlays a dismissing toast banner above a view's content.
struct ToastModifier: ViewModifier {
    @Binding var toast: ToastMessage?
    let autoDismissAfter: Double
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            
            if let toast = toast {
                ToastView(toast: toast)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100) // sits above the tab bar
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .opacity
                        )
                    )
                    .onAppear {
                        // Announce the toast message to VoiceOver
                        AccessibilityAnnouncement.post(toast.message)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + autoDismissAfter) {
                            withAnimation(.easeOut(duration: 0.25)) {
                                self.toast = nil
                            }
                        }
                    }
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.2)) {
                            self.toast = nil
                        }
                    }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: toast)
    }
}

// MARK: - View Extension

extension View {
    /// Attach a toast notification to any view.
    /// - Parameters:
    ///   - toast: Binding to optional ToastMessage. Set to non-nil to show, nil to dismiss.
    ///   - autoDismissAfter: Seconds before auto-dismiss. Defaults to 2.5s.
    /// - Usage: `.toast($myToast)`
    func toast(_ toast: Binding<ToastMessage?>, autoDismissAfter: Double = 2.5) -> some View {
        modifier(ToastModifier(toast: toast, autoDismissAfter: autoDismissAfter))
    }
}
