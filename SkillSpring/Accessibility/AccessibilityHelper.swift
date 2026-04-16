// MARK: - AccessibilityHelper.swift
// SkillSpryng Accessibility Foundation
//
// Provides reusable View modifiers and helpers to ensure WCAG 2.1 AA compliance
// across the entire app:
//   • VoiceOver labels, hints, and traits
//   • Minimum 44×44pt touch targets
//   • Grouped card elements
//   • Dynamic announcement support

import SwiftUI

// MARK: - View Extensions

extension View {

    // -------------------------------------------------------------------------
    // MARK: Decorative / Hidden Elements
    // -------------------------------------------------------------------------

    /// Hides a purely decorative element from VoiceOver.
    func accessibilityDecorative() -> some View {
        self.accessibilityHidden(true)
    }

    // -------------------------------------------------------------------------
    // MARK: Semantic Traits
    // -------------------------------------------------------------------------

    /// Marks a text element as a section header for VoiceOver navigation.
    func accessibilityHeader() -> some View {
        self.accessibilityAddTraits(.isHeader)
    }

    /// Marks an element as a static image with a descriptive label.
    func accessibilityImage(label: String) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isImage)
    }

    // -------------------------------------------------------------------------
    // MARK: Interactive Elements
    // -------------------------------------------------------------------------

    /// Full button accessibility: label + hint + `.isButton` trait.
    func accessibilityButton(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "Double-tap to \(label.lowercased())")
            .accessibilityAddTraits(.isButton)
    }

    /// Ensures interactive elements meet the minimum touch target (52pt for Child Mode, 44pt otherwise).
    func accessibilityMinTouchTarget() -> some View {
        let isChildMode = UserDefaults.standard.bool(forKey: "isChildMode")
        let size: CGFloat = isChildMode ? 52 : 44
        return self.frame(minWidth: size, minHeight: size)
    }

    // -------------------------------------------------------------------------
    // MARK: Card Grouping
    // -------------------------------------------------------------------------

    /// Collapses all sub-views into a single VoiceOver element with a combined label.
    func accessibilityCardGroup(label: String, hint: String? = nil, isButton: Bool = false) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .modifier(OptionalHintModifier(hint: hint))
            .modifier(OptionalButtonTraitModifier(isButton: isButton))
    }

    // -------------------------------------------------------------------------
    // MARK: Form Fields
    // -------------------------------------------------------------------------

    /// Labels a text field for VoiceOver with an explicit label (not the placeholder).
    func accessibilityField(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.allowsDirectInteraction)
    }

    // -------------------------------------------------------------------------
    // MARK: Progress / Value
    // -------------------------------------------------------------------------

    /// Announces a numeric progress value for VoiceOver.
    func accessibilityProgress(label: String, value: Double, total: Double = 100) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityValue("\(Int((value / total) * 100)) percent")
    }
}

// MARK: - Private Modifier Helpers

private struct OptionalHintModifier: ViewModifier {
    let hint: String?
    func body(content: Content) -> some View {
        if let hint = hint {
            content.accessibilityHint(hint)
        } else {
            content
        }
    }
}

private struct OptionalButtonTraitModifier: ViewModifier {
    let isButton: Bool
    func body(content: Content) -> some View {
        if isButton {
            content.accessibilityAddTraits(.isButton)
        } else {
            content
        }
    }
}

// MARK: - VoiceOver Announcements

enum AccessibilityAnnouncement {
    /// Posts a VoiceOver announcement for dynamic content changes (e.g. toasts).
    static func post(_ message: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }

    /// Posts a VoiceOver screen-changed notification (e.g. navigation).
    static func screenChanged() {
        UIAccessibility.post(notification: .screenChanged, argument: nil)
    }

    /// Posts a layout-changed notification.
    static func layoutChanged() {
        UIAccessibility.post(notification: .layoutChanged, argument: nil)
    }
}
