import UIKit

/// Wraps UIKit haptic generators for easy use across the app.
/// Per Apple HIG: use haptics to confirm actions and communicate results.
struct HapticManager {
    
    /// Use for successful completions — e.g. Face ID success, form submitted
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    /// Use for errors — e.g. Face ID failed, validation error
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    /// Use for warnings — e.g. toggling off a feature, low balance
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
    
    /// Use for light UI interactions — e.g. tapping a button, selecting a chip
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    /// Use for medium feedback — e.g. confirming a toggle
    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}
