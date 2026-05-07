import UIKit

/// Provides haptic feedback for different interaction types.
/// Uses UIKit haptic generators to give tactile feedback that confirms actions.
/// Per Apple HIG: use haptics to communicate app state and confirm user actions.
struct HapticManager {
    
    /// Triggers success haptic — a quick double tap pattern.
    /// Use for: Face ID success, form submission success, session booking confirmed.
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    /// Triggers error haptic — a distinct warning pattern.
    /// Use for: Face ID failed, validation errors, session cancelled.
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    /// Triggers warning haptic — subtle alert pattern.
    /// Use for: Toggling off important features, low wallet balance warnings.
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
    
    /// Light impact feedback for subtle interactions.
    /// Use for: Button taps, chip selection in a tag list.
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    /// Medium impact feedback for moderate interactions.
    /// Use for: Toggle switches, carousel scrolling, confirming selections.
    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}
