//
//  ColorPalette.swift
//  taskly
//
//  Color palette extracted from design prompt
//  All colors support automatic light/dark mode switching
//

import SwiftUI

enum ColorPalette {
    // MARK: - Action Colors
    
    /// Primary action color (macOS Blue)
    /// Light: #007AFF, Dark: #0A84FF
    static let primaryAction = Color("PrimaryAction")
    
    /// Success/Rollover color (macOS Green)
    /// Light: #34C759, Dark: #32D74B
    static let success = Color("Success")
    
    /// Destructive action color (macOS Red)
    /// Light: #FF3B30, Dark: #FF453A
    static let destructive = Color("Destructive")
    
    // MARK: - Background Colors
    
    /// Main background color
    /// Light: #F5F5F7, Dark: #1C1C1E
    static let background = Color("Background")
    
    /// Surface color for glass cards (with opacity)
    /// Light: White 80% opacity, Dark: Dark gray 75% opacity
    static let surface = Color("Surface")
    
    // MARK: - Text Colors
    
    /// Primary text color
    /// Light: Black 87% opacity, Dark: White 90% opacity
    static let textPrimary = Color("TextPrimary")
    
    /// Secondary text color
    /// Light: Black 60% opacity, Dark: White 70% opacity
    static let textSecondary = Color("TextSecondary")
    
    /// Tertiary text color
    /// Light: Black 38% opacity, Dark: White 50% opacity
    static let textTertiary = Color("TextTertiary")
    
    // MARK: - Border Colors
    
    /// Border/separator color
    /// Light: #E5E5E5, Dark: #38383A
    static let border = Color("Border")
}
