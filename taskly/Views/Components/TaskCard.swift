//
//  TaskCard.swift
//  taskly
//
//  Created by Owen on 1/25/26.
//

import SwiftUI

struct TaskCard: View {
    let task: TaskItem
    
    private var priorityText: String {
        switch task.priorityLevel {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                // Custom Checkbox
                Circle()
                    .strokeBorder(task.isCompleted ? Color.purple : .secondary.opacity(0.3), lineWidth: 2)
                    .background(task.isCompleted ? Color.purple : .clear)
                    .frame(width: 20, height: 20)
                    .overlay(task.isCompleted ? Image(systemName: "checkmark").font(.caption2).bold().foregroundColor(.white) : nil)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.system(size: 16, weight: .semibold))
                        .strikethrough(task.isCompleted)
                        .foregroundColor(task.isCompleted ? .secondary : .primary)
                    
                    if !task.taskDescription.isEmpty {
                        Text(task.taskDescription)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Priority/Project Tag
                Text(priorityText)
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .foregroundColor(.orange)
                    .cornerRadius(6)
            }
        }
        .padding(20)
        .glassCardStyle()
    }
}
