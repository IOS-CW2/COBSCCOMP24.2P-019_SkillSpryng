// MARK: - AppTheme.swift
// SkillSpryng Design System
// Single source of truth for all colors, typography, gradients, and spacing.
// Usage: AppTheme.Colors.primary, AppTheme.Typography.title, etc.

import SwiftUI

// MARK: - Color Hex Extension (shared utility)
/// Converts hex color strings (3, 6, or 8 character) into SwiftUI Color objects.
/// Supports short format (#1D9), standard format (#1D9E75), and alpha format (#1D9E75FF).
extension Color {
    /// Initializes a Color from a hex string.
    /// Handles RGB (6 chars), RGBA (8 chars), and shorthand (3 chars) hex values.
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

// MARK: - AppTheme Namespace
enum AppTheme {

    // -------------------------------------------------------------------------
    // MARK: Colors
    // -------------------------------------------------------------------------
    /// All colors used throughout the app. Pulled from the brand guideline.
    /// Text colors automatically switch between dark and light modes.
    enum Colors {
        /// Main brand green — appears on icons, tags, toggles, and links.
        /// This is the core identity color for SkillSpryng.
        static let primary       = Color(hex: "1D9E75")

        /// Lighter version of the brand green for subtle highlights and backgrounds.
        /// Used on success states and top of card gradients.
        static let primaryLight  = Color(hex: "2DBF8E")
        
        /// Bright accent green — draws attention to match percentages and key metrics.
        static let accent        = Color(hex: "27E246")

        /// Darker green for button gradients — creates depth when combined with primary.
        static let buttonStart   = Color(hex: "1D9E75")
        static let buttonEnd     = Color(hex: "0F7A5A")

        /// Standard system backgrounds that respect user's dark/light mode preference.
        static let background    = Color(.systemBackground)
        /// Light gray used for card backgrounds and chip fills.
        static let surfaceLight  = Color(.systemGray6)
        /// Mid gray for borders and dividers.
        static let surfaceMid    = Color(.systemGray5)

        /// Text colors that automatically adapt to dark and light modes.
        static let textPrimary   = Color(.label)
        static let textSecondary = Color(.secondaryLabel)
        static let textTertiary  = Color(.tertiaryLabel)

        /// Semantic colors for user feedback — success, warnings, and errors.
        static let success       = Color(hex: "2DBF8E")
        static let warning       = Color.orange
        static let error         = Color.red
        static let info          = Color(hex: "1D9E75")

        /// Colors for the onboarding flow leaf icon animation.
        static let onboardingTop    = Color(hex: "1D9E75")
        static let onboardingBottom = Color(hex: "0F7A5A")
    }

    // -------------------------------------------------------------------------
    // MARK: Gradients
    // -------------------------------------------------------------------------
    /// Linear gradients for buttons, cards, and visual elements.
    /// These add depth and visual interest while maintaining brand consistency.
    enum Gradients {
        /// Main action button gradient — goes from bright green to darker green.
        /// Creates a subtle depth effect that helps buttons stand out.
        static let primaryButton = LinearGradient(
            gradient: Gradient(colors: [Colors.buttonStart, Colors.buttonEnd]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        /// Used on streak and achievement cards to highlight accomplishments.
        /// Transitions from light green to the brand green for a premium feel.
        static let streakCard = LinearGradient(
            gradient: Gradient(colors: [Colors.primaryLight, Colors.primary]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        /// Very subtle gradient for match cards in the Discover section.
        /// Uses low opacity to stay in the background without overpowering content.
        static let heroCard = LinearGradient(
            gradient: Gradient(colors: [Colors.primaryLight.opacity(0.1), Colors.primary.opacity(0.1)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        /// Gradient fill for charts and graphs — fades from green to transparent.
        /// Makes analytics sections pop without being distracting.
        static let chartFill = LinearGradient(
            gradient: Gradient(colors: [Colors.primary.opacity(0.2), Color.white.opacity(0)]),
            startPoint: .top,
            endPoint: .bottom
        )

        /// Animation gradient for the onboarding leaf icon.
        /// Cycles through green shades during the intro flow.
        static let onboarding = LinearGradient(
            gradient: Gradient(colors: [Colors.onboardingTop, Colors.onboardingBottom]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // -------------------------------------------------------------------------
    // MARK: Typography — Dynamic Type
    // All text uses system font styles so they automatically scale when users
    // enable Larger Text in accessibility settings. This ensures readability
    // for everyone, including those with vision needs.
    // -------------------------------------------------------------------------
    /// Font sizes throughout the app. These use dynamic type so they adapt
    /// to user accessibility preferences automatically.
    enum Typography {
        /// Hero-level titles for the biggest sections and modal headers.
        /// Bold and large to grab attention.
        static let displayTitle = Font.largeTitle.weight(.bold)
        static let largeTitle  = Font.largeTitle.weight(.bold)
        /// Page section titles — big and bold.
        static let title       = Font.title.weight(.bold)
        static let title2      = Font.title2.weight(.bold)
        static let title3      = Font.title3.weight(.semibold)
        /// Headers for subsections within a page.
        static let sectionTitle = Font.title3.weight(.bold)

        /// Main text sizes for readable content.
        /// Headline is slightly bolder than body text.
        static let headline    = Font.headline
        static let body        = Font.body
        static let callout     = Font.callout

        /// Smaller supporting text for metadata, timestamps, or descriptions.
        static let subheadline = Font.subheadline
        static let footnote    = Font.footnote
        /// Small enough for badges and compact labels.
        static let caption     = Font.caption
        static let caption2    = Font.caption2

        /// Extra small text for special cases — keep sparingly to maintain readability.
        static let badge         = Font.system(.caption2).weight(.bold)
        static let sectionHeader = Font.system(.footnote).weight(.bold)
        static let micro         = Font.system(.caption2)
    }

    // -------------------------------------------------------------------------
    // MARK: Spacing & Radius
    // -------------------------------------------------------------------------
    /// Consistent spacing values to maintain visual rhythm throughout the app.
    /// Using a scale (4, 8, 16, 24, 32, 48) keeps padding and margins uniform.
    enum Spacing {
        static let xs:  CGFloat = 4   // Minimal space — buttons, tight groups
        static let sm:  CGFloat = 8   // Small — between elements in tight layouts
        static let md:  CGFloat = 16  // Medium — standard padding inside cards
        static let lg:  CGFloat = 24  // Large — main section padding
        static let xl:  CGFloat = 32  // Extra large — between major sections
        static let xxl: CGFloat = 48  // Extra extra large — page-level padding
    }

    /// Border radius values for a consistent rounded look.
    /// Larger values create softer, more modern feels.
    enum Radius {
        static let sm:  CGFloat = 8    // Small — subtle rounding on input fields
        static let md:  CGFloat = 12   // Medium — standard cards and buttons
        static let lg:  CGFloat = 16   // Large — prominent cards
        static let xl:  CGFloat = 24   // Extra large — hero sections
        static let full: CGFloat = 999 // Circular — perfect for pills and avatars
    }

    // -------------------------------------------------------------------------
    // MARK: Shadows
    // -------------------------------------------------------------------------
    /// Shadow definitions for depth and layering.
    /// Subtle shadows help cards and modals stand out from the background.
    enum Shadow {
        /// Soft shadow for regular cards — just enough depth without being heavy.
        static let card   = (color: Color.black.opacity(0.05), radius: CGFloat(10), x: CGFloat(0), y: CGFloat(5))
        /// Slightly darker shadow for buttons — gives them a clickable feel.
        static let button = (color: Color.black.opacity(0.1),  radius: CGFloat(8),  x: CGFloat(0), y: CGFloat(4))
        /// Strong shadow for modals and overlays — shows they're floating above content.
        static let modal  = (color: Color.black.opacity(0.1),  radius: CGFloat(20), x: CGFloat(0), y: CGFloat(8))
    }
}
