//
//  HeaderView.swift
//  taskly
//
//  Top header bar with search and actions
//

import SwiftUI

struct HeaderView: View {
    @Binding var searchText: String
    let onAddTask: () -> Void
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Hamburger menu (optional)
            Button(action: {}) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 16))
                    .foregroundColor(ColorPalette.textSecondary)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Search Bar with glass effect
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: SFSymbols.search)
                    .font(.system(size: 14))
                    .foregroundColor(ColorPalette.textTertiary)
                
                TextField("Search tasks...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.sora(size: 14))
                    .foregroundColor(ColorPalette.textPrimary)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .frame(width: 200)
            .background(ColorPalette.surface.opacity(0.8))
            .background(.ultraThinMaterial)
            .cornerRadius(DesignSystem.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
            )
            
            // Add Task Button
            Button(action: onAddTask) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(ColorPalette.primaryAction)
                    .cornerRadius(DesignSystem.CornerRadius.sm)
                    .shadow(color: ColorPalette.primaryAction.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(ColorPalette.background.opacity(0.5))
        .background(.ultraThinMaterial)
    }
}
