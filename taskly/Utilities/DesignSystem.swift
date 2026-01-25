//
//  DesignSystem.swift
//  taskly
//
//  Design system constants and utilities
//

import SwiftUI

/// Design system constants
enum DesignSystem {
    // MARK: - Spacing (8px grid)
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    enum CornerRadius {
        static let sm: CGFloat = 6
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
    }
    
    // MARK: - Shadows
    enum Shadow {
        // Light mode shadows
        static let lightPrimary = ShadowStyle(
            color: Color.black.opacity(0.05),
            radius: 8,
            x: 0,
            y: 2
        )
        
        static let lightElevated = ShadowStyle(
            color: Color.black.opacity(0.08),
            radius: 16,
            x: 0,
            y: 4
        )
        
        // Dark mode shadows
        static let darkPrimary = ShadowStyle(
            color: Color.black.opacity(0.2),
            radius: 8,
            x: 0,
            y: 2
        )
        
        static let darkElevated = ShadowStyle(
            color: Color.black.opacity(0.3),
            radius: 16,
            x: 0,
            y: 4
        )
    }
    
    // MARK: - Glass Effect
    enum Glass {
        static let blurRadius: CGFloat = 30
        static let lightOpacity: Double = 0.8
        static let darkOpacity: Double = 0.75
    }
}

/// Shadow style structure
struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Modifiers

extension View {
    /// Apply glass effect with blur and translucency
    func glassEffect(opacity: Double = DesignSystem.Glass.lightOpacity) -> some View {
        self
            .background(
                Material.ultraThinMaterial
                    .opacity(opacity)
            )
            .background(
                Color.white.opacity(0.1)
            )
    }
    
    /// Apply shadow based on current color scheme
    func adaptiveShadow(style: ShadowStyle, elevated: Bool = false) -> some View {
        self.shadow(
            color: style.color,
            radius: style.radius,
            x: style.x,
            y: style.y
        )
    }
    
    /// Apply card styling with glass effect and shadow
    func glassCard() -> some View {
        self
            .background(ColorPalette.surface)
            .cornerRadius(DesignSystem.CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .stroke(ColorPalette.border.opacity(0.2), lineWidth: 1)
            )
            .shadow(
                color: Color.black.opacity(0.05),
                radius: 8,
                x: 0,
                y: 2
            )
    }
}
