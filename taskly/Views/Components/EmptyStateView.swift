//
//  EmptyStateView.swift
//  taskly
//
//  Reusable empty state component
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let buttonTitle: String?
    let buttonAction: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        message: String,
        buttonTitle: String? = nil,
        buttonAction: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    ColorPalette.primaryAction.opacity(0.05),
                    Color.purple.opacity(0.05),
                    Color.pink.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: DesignSystem.Spacing.xl) {
                // Icon Card with glass effect
                ZStack(alignment: .topTrailing) {
                    // Glass card background
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .fill(.ultraThinMaterial)
                        .frame(width: 140, height: 140)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 8)
                    
                    // Icon background square
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .fill(ColorPalette.primaryAction.opacity(0.12))
                        .frame(width: 100, height: 100)
                        .padding(DesignSystem.Spacing.md)
                    
                    // Main icon
                    Image(systemName: icon)
                        .font(.system(size: 56, weight: .ultraLight))
                        .foregroundColor(ColorPalette.primaryAction)
                        .padding(DesignSystem.Spacing.md)
                    
                    // Checkmark badge in top-right corner
                    ZStack {
                        Circle()
                            .fill(ColorPalette.primaryAction)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .offset(x: 8, y: -8)
                }
                
                // Title
                Text(title)
                    .font(.soraBold(size: 28))
                    .foregroundColor(ColorPalette.textPrimary)
                
                // Message
                Text(message)
                    .font(.sora(size: 15))
                    .foregroundColor(ColorPalette.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.xxl)
                    .lineSpacing(4)
                
                // Button
                if let buttonTitle = buttonTitle, let buttonAction = buttonAction {
                    Button(action: buttonAction) {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .semibold))
                            Text(buttonTitle)
                                .font(.soraMedium(size: 14))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.vertical, DesignSystem.Spacing.md)
                        .background(ColorPalette.primaryAction)
                        .cornerRadius(DesignSystem.CornerRadius.md)
                        .shadow(color: ColorPalette.primaryAction.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
