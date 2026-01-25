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
    
    /// Apply glass card style with enhanced shadows
    func glassCardStyle() -> some View {
        self
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            // 1. Inner Border (High-end edge highlight)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(0.5), lineWidth: 0.5)
            )
            // 2. Soft Drop Shadow
            .shadow(color: .black.opacity(0.03), radius: 1, x: 0, y: 1)
            // 3. Diffused Ambient Shadow
            .shadow(color: .black.opacity(0.06), radius: 15, x: 0, y: 10)
    }
}

// MARK: - Button Styles

struct GlowButtonStyle: ButtonStyle {
    @State private var isHovered = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    // The Primary Gradient
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                    
                    // The Hover Overlay (brightens the button)
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.white.opacity(isHovered ? 0.1 : 0))
                }
            )
            // Layered Shadows for the "Glow" look
            .shadow(color: .blue.opacity(isHovered ? 0.5 : 0.3), radius: isHovered ? 15 : 10, x: 0, y: 8)
            .shadow(color: .blue.opacity(0.2), radius: 2, x: 0, y: 2)
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

// MARK: - Bloom Button Component

struct BloomButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // The "Bloom" shadow
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.opacity(0.4))
                    .frame(width: 32, height: 32)
                    .blur(radius: 8)
                    .offset(y: 4)
                
                // The Button
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .bold))
                    .frame(width: 36, height: 36)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .buttonStyle(.plain)
    }
}
