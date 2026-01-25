//
//  FontHelper.swift
//  taskly
//
//  Sora font family helper and extension
//

import SwiftUI
import AppKit
import CoreText

extension Font {
    // MARK: - Sora Font Family
    
    /// Sora Thin (100)
    static func soraThin(size: CGFloat) -> Font {
        return .custom("Sora-Thin", size: size)
    }
    
    /// Sora ExtraLight (200)
    static func soraExtraLight(size: CGFloat) -> Font {
        return .custom("Sora-ExtraLight", size: size)
    }
    
    /// Sora Light (300)
    static func soraLight(size: CGFloat) -> Font {
        return .custom("Sora-Light", size: size)
    }
    
    /// Sora Regular (400)
    static func sora(size: CGFloat) -> Font {
        return .custom("Sora-Regular", size: size)
    }
    
    /// Sora SemiBold (600)
    static func soraSemiBold(size: CGFloat) -> Font {
        return .custom("Sora-SemiBold", size: size)
    }
    
    /// Sora Bold (700)
    static func soraBold(size: CGFloat) -> Font {
        return .custom("Sora-Bold", size: size)
    }
    
    /// Sora ExtraBold (800)
    static func soraExtraBold(size: CGFloat) -> Font {
        return .custom("Sora-ExtraBold", size: size)
    }
    
    /// Sora Medium (500) - Falls back to Regular if Medium weight not available
    static func soraMedium(size: CGFloat) -> Font {
        // Note: Sora doesn't have a Medium weight, so we use SemiBold as a close alternative
        return .custom("Sora-SemiBold", size: size)
    }
    
    // MARK: - Typography System (from design prompt)
    
    /// Title/Date text - 20-24pt, Semibold
    static var soraTitle: Font {
        return .soraSemiBold(size: 20)
    }
    
    /// Task text - 15pt, Regular
    static var soraTask: Font {
        return .sora(size: 15)
    }
    
    /// Subtask text - 14pt, Regular
    static var soraSubtask: Font {
        return .sora(size: 14)
    }
    
    /// Button text - 14pt, Medium
    static var soraButton: Font {
        return .soraMedium(size: 14)
    }
    
    /// Stats text - 13pt, Regular
    static var soraStats: Font {
        return .sora(size: 13)
    }
}

// MARK: - Font Registration Helper

class FontHelper {
    /// Register all Sora font files found in the bundle
    /// Call this in your App's init or scene phase
    static func registerFonts() {
        // All available Sora font weights
        let fontNames = [
            "Sora-Thin",
            "Sora-ExtraLight",
            "Sora-Light",
            "Sora-Regular",
            "Sora-SemiBold",
            "Sora-Bold",
            "Sora-ExtraBold"
        ]
        
        var registeredCount = 0
        var failedCount = 0
        
        for fontName in fontNames {
            if let fontURL = Bundle.main.url(forResource: fontName, withExtension: "ttf") {
                var error: Unmanaged<CFError>?
                if CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error) {
                    print("✅ Successfully registered font: \(fontName)")
                    registeredCount += 1
                } else {
                    if let error = error?.takeRetainedValue() {
                        let errorDescription = CFErrorCopyDescription(error) as String? ?? "Unknown error"
                        // Check if error is because font is already registered
                        if errorDescription.contains("already registered") || errorDescription.contains("duplicate") {
                            print("ℹ️ Font \(fontName) already registered")
                            registeredCount += 1
                        } else {
                            print("❌ Failed to register font \(fontName): \(errorDescription)")
                            failedCount += 1
                        }
                    } else {
                        print("⚠️ Font \(fontName) registration returned false (may already be registered)")
                        registeredCount += 1
                    }
                }
            } else {
                print("⚠️ Font file not found in bundle: \(fontName).ttf")
                failedCount += 1
            }
        }
        
        print("\n📊 Font Registration Summary:")
        print("   ✅ Registered: \(registeredCount)")
        print("   ❌ Failed: \(failedCount)")
        print("   📦 Total: \(fontNames.count)")
    }
    
    /// List all available Sora fonts (useful for debugging)
    static func listAvailableFonts() {
        let fontFamilies = NSFontManager.shared.availableFontFamilies
        let soraFonts = fontFamilies.filter { $0.contains("Sora") }
        
        print("\n🔍 Available Sora Fonts:")
        if soraFonts.isEmpty {
            print("   ⚠️ No Sora fonts found. Make sure fonts are registered.")
        } else {
            for family in soraFonts.sorted() {
                print("   ✅ \(family)")
            }
        }
        
        // Also check for specific font names
        print("\n🔍 Checking for specific Sora font files in bundle:")
        let fontNames = ["Sora-Thin", "Sora-ExtraLight", "Sora-Light", "Sora-Regular", 
                        "Sora-SemiBold", "Sora-Bold", "Sora-ExtraBold"]
        for fontName in fontNames {
            if Bundle.main.url(forResource: fontName, withExtension: "ttf") != nil {
                print("   ✅ \(fontName).ttf found in bundle")
            } else {
                print("   ❌ \(fontName).ttf NOT found in bundle")
            }
        }
    }
}
