//
//  NewTaskModal.swift
//  taskly
//
//  Modal for creating new tasks
//

import SwiftUI
import SwiftData

struct NewTaskModal: View {
    @Binding var isPresented: Bool
    @State private var taskTitle = ""
    @State private var taskNotes = ""
    @State private var priority = "Med"
    @State private var isFlagged = false
    @State private var showValidationError = false
    @State private var isCreating = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("New Task")
                .font(.headline)
                .foregroundColor(ColorPalette.textPrimary)
            
            VStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading, spacing: 4) {
                    TextField("What needs to be done?", text: $taskTitle)
                        .font(.system(size: 24, weight: .semibold))
                        .textFieldStyle(.plain)
                        .foregroundColor(ColorPalette.textPrimary)
                        .onSubmit {
                            if !taskTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                                createTask()
                            }
                        }
                    
                    if showValidationError && taskTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                        Text("Task title is required")
                            .font(.caption)
                            .foregroundColor(ColorPalette.destructive)
                    }
                }
                
                HStack {
                    Image(systemName: "text.alignleft")
                        .foregroundStyle(.secondary)
                    TextField("Description or notes...", text: $taskNotes)
                        .textFieldStyle(.plain)
                        .foregroundColor(ColorPalette.textPrimary)
                }
                .padding(12)
                .background(ColorPalette.surface.opacity(0.5))
                .cornerRadius(8)
            }
            
            // Grid for Due Date and Project
            HStack(spacing: 20) {
                ModalInputPicker(label: "Due Date", value: "Today", icon: "calendar")
                ModalInputPicker(label: "Project", value: "None", icon: nil, hasChevron: true)
            }
            
            // Priority Segmented Control
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Priority").font(.caption).bold().foregroundStyle(.secondary)
                    HStack(spacing: 4) {
                        ForEach(["Low", "Med", "High"], id: \.self) { p in
                            Text(p)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(priority == p ? ColorPalette.textPrimary : ColorPalette.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    ZStack {
                                        // Selected state with depth
                                        if priority == p {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(ColorPalette.surface)
                                                .shadow(color: .black.opacity(colorScheme == .dark ? 0.4 : 0.1), radius: 4, x: 0, y: 2)
                                                .shadow(color: .white.opacity(colorScheme == .dark ? 0.1 : 0.3), radius: 1, x: 0, y: -1)
                                        }
                                    }
                                )
                                .overlay(
                                    // Inner border for selected
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(priority == p ? Color.white.opacity(colorScheme == .dark ? 0.15 : 0.3) : Color.clear, lineWidth: 0.5)
                                )
                                .onTapGesture { priority = p }
                        }
                    }
                    .padding(4)
                    .background(
                        ZStack {
                            // Recessed background container
                            RoundedRectangle(cornerRadius: 10)
                                .fill(ColorPalette.surface.opacity(0.3))
                            
                            // Inner shadow for depth
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            .black.opacity(colorScheme == .dark ? 0.3 : 0.1),
                                            .clear
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 1
                                )
                        }
                    )
                    .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.08), radius: 8, x: 0, y: 4)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Flagged").font(.caption).bold().foregroundStyle(.secondary)
                    Button(action: { isFlagged.toggle() }) {
                        HStack {
                            Image(systemName: "flag")
                                .foregroundStyle(isFlagged ? ColorPalette.primaryAction : ColorPalette.textSecondary)
                            Text(isFlagged ? "Flagged" : "None")
                                .foregroundColor(ColorPalette.textPrimary)
                            Spacer()
                        }
                        .font(.system(size: 14))
                        .padding(10)
                        .background(ColorPalette.surface.opacity(0.5))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isFlagged ? ColorPalette.primaryAction.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Action Buttons
            HStack {
                Spacer()
                Button("Cancel") { 
                    resetForm()
                    isPresented = false 
                }
                .buttonStyle(.plain)
                .foregroundStyle(ColorPalette.textSecondary)
                .disabled(isCreating)
                
                Button("Add Task") { 
                    createTask()
                }
                .buttonStyle(GlowButtonStyle())
                .disabled(isCreating || taskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(isCreating || taskTitle.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
            }
            .padding(.top, 10)
        }
        .padding(30)
        .frame(width: 500)
        .background(ColorPalette.background)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.5 : 0.2), radius: 40, x: 0, y: 20)
        .onChange(of: taskTitle) { oldValue, newValue in
            if showValidationError && !newValue.trimmingCharacters(in: .whitespaces).isEmpty {
                showValidationError = false
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTask() {
        let trimmedTitle = taskTitle.trimmingCharacters(in: .whitespaces)
        
        // Validation
        guard !trimmedTitle.isEmpty else {
            showValidationError = true
            return
        }
        
        isCreating = true
        
        // Convert priority string to enum
        let priorityEnum: TaskPriority = {
            switch priority {
            case "High": return .high
            case "Low": return .low
            default: return .medium
            }
        }()
        
        // Create task
        let task = TaskItem(
            title: trimmedTitle,
            taskDescription: taskNotes,
            dueDate: nil, // TODO: Add due date picker functionality
            priority: priorityEnum,
            isFlagged: isFlagged,
            project: nil // TODO: Add project selection functionality
        )
        
        // Save to SwiftData
        modelContext.insert(task)
        
        do {
            try modelContext.save()
            resetForm()
            isPresented = false
        } catch {
            print("Error creating task: \(error)")
            isCreating = false
        }
    }
    
    private func resetForm() {
        taskTitle = ""
        taskNotes = ""
        priority = "Med"
        isFlagged = false
        showValidationError = false
        isCreating = false
    }
}

// Helper for the small input boxes
struct ModalInputPicker: View {
    let label: String
    let value: String
    var icon: String?
    var hasChevron: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.caption).bold()
                .foregroundStyle(ColorPalette.textSecondary)
            HStack {
                if let icon = icon { 
                    Image(systemName: icon)
                        .foregroundStyle(ColorPalette.textSecondary)
                }
                Text(value)
                    .foregroundColor(ColorPalette.textPrimary)
                Spacer()
                if hasChevron { 
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundStyle(ColorPalette.textSecondary)
                }
            }
            .font(.system(size: 14))
            .padding(10)
            .background(ColorPalette.surface.opacity(0.5))
            .cornerRadius(8)
        }
    }
}
