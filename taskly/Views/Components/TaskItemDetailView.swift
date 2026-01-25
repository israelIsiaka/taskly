//
//  TaskItemDetailView.swift
//  taskly
//
//  Created by Owen on 1/25/26.
//

import SwiftUI

struct TaskItemDetailView: View {
    let task: TaskItem
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Header: Close Button, Share, and Options
            HStack {
                Button(action: { withAnimation(.spring()) { isPresented = false } }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                HStack(spacing: 20) {
                    Image(systemName: "square.and.arrow.up")
                    Image(systemName: "ellipsis")
                }
                .foregroundStyle(.secondary)
            }
            
            // Task Title and Primary Toggle
            HStack(alignment: .top, spacing: 16) {
                Circle()
                    .strokeBorder(task.isCompleted ? Color.purple : .secondary.opacity(0.3), lineWidth: 2)
                    .frame(width: 24, height: 24)
                
                Text(task.title)
                    .font(.system(size: 28, weight: .bold))
                    .lineLimit(3)
            }
            
            // Notes Section
            VStack(alignment: .leading, spacing: 8) {
                Text("NOTES")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.tertiary)
                TextEditor(text: .constant(task.taskDescription))
                    .font(.system(size: 15))
                    .scrollContentBackground(.hidden)
                    .frame(height: 100)
            }
            
            // Subtasks Section
            VStack(alignment: .leading, spacing: 16) {
                Text("SUBTASKS")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.tertiary)
                
                if let subtasks = task.subtasks, !subtasks.isEmpty {
                    ForEach(subtasks) { subtask in
                        HStack(spacing: 12) {
                            Image(systemName: subtask.isCompleted ? "checkmark.square.fill" : "square")
                                .foregroundStyle(subtask.isCompleted ? .purple : .secondary)
                            Text(subtask.title)
                                .font(.system(size: 14))
                                .strikethrough(subtask.isCompleted)
                                .foregroundStyle(subtask.isCompleted ? .secondary : .primary)
                        }
                    }
                }
                
                Button("+ Add Subtask") { }
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            // Meta Info (Due Date, Project, etc.)
            VStack(spacing: 20) {
                DetailMetaRow(icon: "calendar", label: "Due Date", value: "Tomorrow, 5:00 PM")
                DetailMetaRow(icon: "folder", label: "Project", value: "MARKETING", badgeColor: .purple)
                DetailMetaRow(icon: "exclamationmark.triangle", label: "Priority", value: "HIGH", badgeColor: .orange)
                DetailMetaRow(icon: "flag", label: "Flag", isToggle: true)
            }
            
            Spacer()
            
            // Footer
            HStack {
                Text("CREATED JAN 25").font(.system(size: 10, weight: .bold)).foregroundStyle(.tertiary)
                Spacer()
                Image(systemName: "trash").foregroundStyle(.red.opacity(0.7))
            }
        }
        .padding(32)
        .frame(width: 400) // Fixed width for the slide-in panel
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .fill(.gray.opacity(0.1))
                .frame(width: 1)
                .padding(.vertical),
            alignment: .leading
        )
    }
}

struct DetailMetaRow: View {
    let icon: String
    let label: String
    var value: String? = nil
    var badgeColor: Color? = nil
    var isToggle: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon).frame(width: 20)
            Text(label).font(.system(size: 14))
            Spacer()
            if let val = value {
                Text(val)
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(badgeColor?.opacity(0.1) ?? .clear)
                    .foregroundStyle(badgeColor ?? .primary)
                    .cornerRadius(4)
            } else if isToggle {
                Toggle("", isOn: .constant(false)).labelsHidden()
            }
        }
        .foregroundStyle(.secondary)
    }
}
