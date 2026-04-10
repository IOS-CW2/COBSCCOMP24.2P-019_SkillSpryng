// MARK: - AppTheme.swift
// SkillSpryng Design System
// Single source of truth for all colors, typography, gradients, and spacing.
// Usage: AppTheme.Colors.primary, AppTheme.Typography.title, etc.

import SwiftUI

// MARK: - Color Hex Extension (shared utility)
extension Color {
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
    enum Colors {
        // Primary Brand Green — used for icons, tags, toggles, links
        // Brand color: #1D9E75
        static let primary       = Color(hex: "1D9E75")  // SkillSpryng Green

        // Lighter brand green — used for checkmark circle, streak card top
        static let primaryLight  = Color(hex: "2DBF8E")  // Lighter SkillSpryng Green
        
        // Brand Accent — used for percentage matches and highlights
        static let accent        = Color(hex: "27E246")

        // Button gradient — LEFT stop
        static let buttonStart   = Color(hex: "1D9E75")

        // Button gradient — RIGHT stop
        static let buttonEnd     = Color(hex: "0F7A5A")

        // Background shades
        static let background    = Color(.systemBackground)
        static let surfaceLight  = Color(.systemGray6)   // card backgrounds, chip fill
        static let surfaceMid    = Color(.systemGray5)   // dividers, borders

        // Text
        static let textPrimary   = Color(.label)         // adapts dark/light
        static let textSecondary = Color(.secondaryLabel)
        static let textTertiary  = Color(.tertiaryLabel)

        // Semantic
        static let success       = Color(hex: "2DBF8E")
        static let warning       = Color.orange
        static let error         = Color.red
        static let info          = Color(hex: "1D9E75")

        // Onboarding / SignIn — leaf icon gradient
        static let onboardingTop    = Color(hex: "1D9E75")
        static let onboardingBottom = Color(hex: "0F7A5A")
    }

    // -------------------------------------------------------------------------
    // MARK: Gradients
    // -------------------------------------------------------------------------
    enum Gradients {
        /// Main CTA button gradient (green → blue). Used across all PrimaryButtons.
        static let primaryButton = LinearGradient(
            gradient: Gradient(colors: [Colors.buttonStart, Colors.buttonEnd]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        /// Streak / hero card gradient (light green → brand green)
        static let streakCard = LinearGradient(
            gradient: Gradient(colors: [Colors.primaryLight, Colors.primary]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        /// Discover hero match card background
        static let heroCard = LinearGradient(
            gradient: Gradient(colors: [Colors.primaryLight.opacity(0.1), Colors.primary.opacity(0.1)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        /// Chart / analytics gradient fill (semi-transparent underlay)
        static let chartFill = LinearGradient(
            gradient: Gradient(colors: [Colors.primary.opacity(0.2), Color.white.opacity(0)]),
            startPoint: .top,
            endPoint: .bottom
        )

        /// Onboarding leaf icon gradient
        static let onboarding = LinearGradient(
            gradient: Gradient(colors: [Colors.onboardingTop, Colors.onboardingBottom]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // -------------------------------------------------------------------------
    // MARK: Typography
    // -------------------------------------------------------------------------
    enum Typography {
        // Page-level titles
        static let largeTitle  = Font.system(size: 34, weight: .bold)
        static let title       = Font.system(size: 28, weight: .bold)
        static let title2      = Font.system(size: 22, weight: .bold)
        static let title3      = Font.system(size: 20, weight: .semibold)

        // Body
        static let headline    = Font.system(size: 17, weight: .semibold)
        static let body        = Font.system(size: 17, weight: .regular)
        static let callout     = Font.system(size: 16, weight: .regular)

        // Supporting
        static let subheadline = Font.system(size: 15, weight: .regular)
        static let footnote    = Font.system(size: 13, weight: .regular)
        static let caption     = Font.system(size: 12, weight: .regular)
        static let caption2    = Font.system(size: 11, weight: .regular)

        // Labels / badges
        static let badge       = Font.system(size: 10, weight: .bold)
        static let sectionHeader = Font.system(size: 13, weight: .bold)
    }

    // -------------------------------------------------------------------------
    // MARK: Spacing & Radius
    // -------------------------------------------------------------------------
    enum Spacing {
        static let xs:  CGFloat = 4
        static let sm:  CGFloat = 8
        static let md:  CGFloat = 16
        static let lg:  CGFloat = 24
        static let xl:  CGFloat = 32
        static let xxl: CGFloat = 48
    }

    enum Radius {
        static let sm:  CGFloat = 8
        static let md:  CGFloat = 12
        static let lg:  CGFloat = 16
        static let xl:  CGFloat = 24
        static let full: CGFloat = 999   // pill / circle
    }

    // -------------------------------------------------------------------------
    // MARK: Shadows
    // -------------------------------------------------------------------------
    enum Shadow {
        static let card   = (color: Color.black.opacity(0.05), radius: CGFloat(10), x: CGFloat(0), y: CGFloat(5))
        static let button = (color: Color.black.opacity(0.1),  radius: CGFloat(8),  x: CGFloat(0), y: CGFloat(4))
        static let modal  = (color: Color.black.opacity(0.1),  radius: CGFloat(20), x: CGFloat(0), y: CGFloat(8))
    }
}
