//
//  TaskCardView.swift
//  taskly
//
//  Task card component
//

import SwiftUI

struct TaskCardView: View {
    let task: TaskItem
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Checkbox
            Button(action: {}) {
                Image(systemName: task.isCompleted ? SFSymbols.checkboxFilled : SFSymbols.checkboxEmpty)
                    .font(.system(size: 18))
                    .foregroundColor(task.isCompleted ? ColorPalette.success : ColorPalette.textTertiary)
            }
            .buttonStyle(.plain)
            
            // Task Content
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(task.title)
                    .font(.sora(size: 15))
                    .foregroundColor(task.isCompleted ? ColorPalette.textTertiary : ColorPalette.textPrimary)
                    .strikethrough(task.isCompleted)
                
                if !task.taskDescription.isEmpty {
                    Text(task.taskDescription)
                        .font(.sora(size: 13))
                        .foregroundColor(ColorPalette.textSecondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Flag indicator
            if task.isFlagged {
                Image(systemName: SFSymbols.flag)
                    .font(.system(size: 14))
                    .foregroundColor(.yellow)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .fill(ColorPalette.surface.opacity(isHovered ? 0.95 : 1.0))
        )
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: isHovered ? 12 : 8, x: 0, y: isHovered ? 4 : 2)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isHovered = hovering
            }
        }
    }
}
