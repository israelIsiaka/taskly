//
//  TaskItemDetailView.swift
//  taskly
//
//  Created by Owen on 1/25/26.
//

import SwiftUI
import SwiftData

struct TaskItemDetailView: View {
    @Bindable var task: TaskItem
    @Binding var isPresented: Bool
    @Environment(\.modelContext) private var modelContext
    
    @State private var editingTitle = false
    @State private var editedTitle = ""
    @State private var editingNotes = false
    @State private var editedNotes = ""
    @State private var showDatePicker = false
    @State private var showPriorityPicker = false
    @State private var newSubtaskText = ""
    @State private var showNewSubtaskField = false
    @State private var editingSubtaskIndex: Int? = nil
    @State private var editingSubtaskText = ""
    @State private var showDeleteConfirmation = false
    
    private var priorityText: String {
        switch task.priorityLevel {
        case .high: return "HIGH"
        case .medium: return "MED"
        case .low: return "LOW"
        }
    }
    
    private var priorityColor: Color {
        switch task.priorityLevel {
        case .high: return .orange
        case .medium: return .blue
        case .low: return .secondary
        }
    }
    
    private var dueDateText: String {
        guard let date = task.dueDate else { return "None" }
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
    }
    
    // Check if task has subtasks
    private var hasSubtasks: Bool {
        guard let subtasks = task.subtasks else { return false }
        return !subtasks.isEmpty
    }
    
    // Check if all subtasks are completed
    private var allSubtasksCompleted: Bool {
        guard let subtasks = task.subtasks, !subtasks.isEmpty else { return false }
        return subtasks.allSatisfy { $0.isCompleted }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Header: Close Button, Share, and Options
            HStack {
                Button(action: { 
                    withAnimation(.spring()) { 
                        isPresented = false 
                    } 
                }) {
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
                Button(action: {
                    // Only allow manual toggle if there are no subtasks
                    if !hasSubtasks {
                        toggleCompletion()
                    }
                }) {
                    Circle()
                        .strokeBorder(task.isCompleted ? Color.purple : .secondary.opacity(0.3), lineWidth: 2)
                        .background(task.isCompleted ? Color.purple : .clear)
                        .frame(width: 24, height: 24)
                        .overlay(
                            task.isCompleted ? 
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white) : nil
                        )
                        .opacity(hasSubtasks ? 0.5 : 1.0) // Dim if disabled
                }
                .buttonStyle(.plain)
                .disabled(hasSubtasks) // Disable if task has subtasks
                
                if editingTitle {
                    TextField("Task title", text: $editedTitle)
                        .font(.system(size: 28, weight: .bold))
                        .textFieldStyle(.plain)
                        .onSubmit {
                            saveTitle()
                        }
                        .onExitCommand {
                            cancelTitleEdit()
                        }
                } else {
                    Text(task.title)
                        .font(.system(size: 28, weight: .bold))
                        .lineLimit(3)
                        .onTapGesture {
                            startEditingTitle()
                        }
                }
            }
            
            // Notes Section
            VStack(alignment: .leading, spacing: 8) {
                Text("NOTES")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.tertiary)
                
                TextEditor(text: Binding(
                    get: { task.taskDescription },
                    set: { 
                        task.taskDescription = $0
                        saveTask()
                    }
                ))
                .font(.system(size: 15))
                .scrollContentBackground(.hidden)
                .frame(height: 100)
                .background(ColorPalette.surface.opacity(0.3))
                .cornerRadius(8)
            }
            
            // Subtasks Section
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("SUBTASKS")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.tertiary)
                    Spacer()
                    Button(action: {
                        showNewSubtaskField = true
                    }) {
                        Text("+ Add Subtask")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.purple)
                    }
                    .buttonStyle(.plain)
                }
                
                // New subtask input
                if showNewSubtaskField {
                    HStack(spacing: 12) {
                        Image(systemName: "circle")
                            .foregroundStyle(.secondary)
                        TextField("New subtask...", text: $newSubtaskText)
                            .font(.system(size: 14))
                            .textFieldStyle(.plain)
                            .onSubmit {
                                addSubtask()
                            }
                        Button(action: addSubtask) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.purple)
                        }
                        .buttonStyle(.plain)
                        Button(action: {
                            showNewSubtaskField = false
                            newSubtaskText = ""
                        }) {
                            Image(systemName: "xmark")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Subtasks list
                if let subtasks = task.subtasks, !subtasks.isEmpty {
                    ForEach(Array(subtasks.enumerated()), id: \.element.id) { index, subtask in
                        HStack(spacing: 12) {
                            Button(action: {
                                toggleSubtask(subtask)
                            }) {
                                Image(systemName: subtask.isCompleted ? "checkmark.square.fill" : "square")
                                    .foregroundStyle(subtask.isCompleted ? .purple : .secondary)
                            }
                            .buttonStyle(.plain)
                            
                            if editingSubtaskIndex == index {
                                TextField("Subtask", text: $editingSubtaskText)
                                    .font(.system(size: 14))
                                    .textFieldStyle(.plain)
                                    .onSubmit {
                                        saveSubtaskEdit(at: index)
                                    }
                            } else {
                                Text(subtask.title)
                                    .font(.system(size: 14))
                                    .strikethrough(subtask.isCompleted)
                                    .foregroundStyle(subtask.isCompleted ? .secondary : .primary)
                                    .onTapGesture {
                                        startEditingSubtask(at: index, text: subtask.title)
                                    }
                            }
                            
                            Spacer()
                            
                            if editingSubtaskIndex == index {
                                Button(action: {
                                    saveSubtaskEdit(at: index)
                                }) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.purple)
                                }
                                .buttonStyle(.plain)
                                Button(action: {
                                    cancelSubtaskEdit()
                                }) {
                                    Image(systemName: "xmark")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            } else {
                                Button(action: {
                                    deleteSubtask(subtask)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary.opacity(0.5))
                                        .font(.system(size: 12))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            
            Divider()
            
            // Meta Info (Due Date, Project, Priority, Flag)
            VStack(spacing: 20) {
                // Due Date
                DatePickerRow(
                    label: "Due Date",
                    date: Binding(
                        get: { task.dueDate ?? Date() },
                        set: { 
                            task.dueDate = $0
                            saveTask()
                        }
                    ),
                    hasDate: Binding(
                        get: { task.dueDate != nil },
                        set: { 
                            if !$0 {
                                task.dueDate = nil
                            } else if task.dueDate == nil {
                                task.dueDate = Date()
                            }
                            saveTask()
                        }
                    ),
                    showPicker: $showDatePicker
                )
                
                // Project (placeholder for now)
                DetailMetaRow(icon: "folder", label: "Project", value: task.project?.name ?? "Inbox", badgeColor: .purple)
                
                // Priority
                PriorityPickerRow(
                    label: "Priority",
                    priority: Binding(
                        get: { task.priorityLevel },
                        set: { 
                            task.priorityLevel = $0
                            saveTask()
                        }
                    ),
                    showPicker: $showPriorityPicker
                )
                
                // Flag
                DetailMetaRow(
                    icon: "flag",
                    label: "Flag",
                    isToggle: true,
                    toggleValue: Binding(
                        get: { task.isFlagged },
                        set: { 
                            task.isFlagged = $0
                            saveTask()
                        }
                    )
                )
            }
            
            Spacer()
            
            // Footer
            HStack {
                Text("CREATED \(formatDate(task.createdAt))")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.tertiary)
                Spacer()
                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    Image(systemName: "trash")
                        .foregroundStyle(.red.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(32)
        .frame(width: 400)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .fill(.gray.opacity(0.1))
                .frame(width: 1)
                .padding(.vertical),
            alignment: .leading
        )
        .alert("Delete Task", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteTask()
            }
        } message: {
            Text("Are you sure you want to delete this task? This action cannot be undone.")
        }
        .onAppear {
            editedTitle = task.title
            editedNotes = task.taskDescription
            // Sync main task completion status with subtasks on load
            updateMainTaskCompletion()
        }
    }
    
    // MARK: - Helper Methods
    
    private func startEditingTitle() {
        editingTitle = true
        editedTitle = task.title
    }
    
    private func saveTitle() {
        task.title = editedTitle.trimmingCharacters(in: .whitespaces)
        if task.title.isEmpty {
            task.title = "Untitled Task"
        }
        saveTask()
        editingTitle = false
    }
    
    private func cancelTitleEdit() {
        editingTitle = false
        editedTitle = task.title
    }
    
    private func toggleCompletion() {
        task.isCompleted.toggle()
        saveTask()
    }
    
    private func addSubtask() {
        let trimmed = newSubtaskText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        let subtask = Subtask(title: trimmed, parentTask: task)
        modelContext.insert(subtask)
        
        if task.subtasks == nil {
            task.subtasks = []
        }
        task.subtasks?.append(subtask)
        
        // Update main task completion status after adding subtask
        updateMainTaskCompletion()
        
        saveTask()
        newSubtaskText = ""
        showNewSubtaskField = false
    }
    
    private func deleteSubtask(_ subtask: Subtask) {
        task.subtasks?.removeAll { $0.id == subtask.id }
        modelContext.delete(subtask)
        
        // Update main task completion status after deleting subtask
        updateMainTaskCompletion()
        
        saveTask()
    }
    
    private func toggleSubtask(_ subtask: Subtask) {
        subtask.isCompleted.toggle()
        subtask.touch()
        
        // Auto-check/uncheck main task based on subtask completion
        updateMainTaskCompletion()
        
        saveTask()
    }
    
    private func updateMainTaskCompletion() {
        // Only update if task has subtasks
        guard hasSubtasks else { return }
        
        // Check main task if all subtasks are completed
        if allSubtasksCompleted && !task.isCompleted {
            task.isCompleted = true
            task.touch()
        }
        // Uncheck main task if any subtask is incomplete
        else if !allSubtasksCompleted && task.isCompleted {
            task.isCompleted = false
            task.touch()
        }
    }
    
    private func startEditingSubtask(at index: Int, text: String) {
        editingSubtaskIndex = index
        editingSubtaskText = text
    }
    
    private func saveSubtaskEdit(at index: Int) {
        guard let subtasks = task.subtasks, index < subtasks.count else { return }
        let trimmed = editingSubtaskText.trimmingCharacters(in: .whitespaces)
        
        if !trimmed.isEmpty {
            subtasks[index].title = trimmed
            subtasks[index].touch()
        } else {
            deleteSubtask(subtasks[index])
        }
        
        saveTask()
        cancelSubtaskEdit()
    }
    
    private func cancelSubtaskEdit() {
        editingSubtaskIndex = nil
        editingSubtaskText = ""
    }
    
    private func saveTask() {
        task.touch()
        do {
            try modelContext.save()
        } catch {
            print("Error saving task: \(error)")
        }
    }
    
    private func deleteTask() {
        modelContext.delete(task)
        do {
            try modelContext.save()
            isPresented = false
        } catch {
            print("Error deleting task: \(error)")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date).uppercased()
    }
}

// MARK: - Supporting Views

struct DetailMetaRow: View {
    let icon: String
    let label: String
    var value: String? = nil
    var badgeColor: Color? = nil
    var isToggle: Bool = false
    var toggleValue: Binding<Bool>? = nil
    
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
            } else if isToggle, let toggle = toggleValue {
                Toggle("", isOn: toggle).labelsHidden()
            }
        }
        .foregroundStyle(.secondary)
    }
}

struct DatePickerRow: View {
    let label: String
    @Binding var date: Date
    @Binding var hasDate: Bool
    @Binding var showPicker: Bool
    
    private var displayText: String {
        guard hasDate else { return "None" }
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: "calendar").frame(width: 20)
            Text(label).font(.system(size: 14))
            Spacer()
            Button(action: {
                showPicker.toggle()
            }) {
                Text(displayText)
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(hasDate ? Color.blue.opacity(0.1) : Color.clear)
                    .foregroundStyle(hasDate ? .blue : .secondary)
                    .cornerRadius(4)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showPicker, arrowEdge: .bottom) {
                VStack(spacing: 12) {
                    Button(action: {
                        hasDate = false
                        showPicker = false
                    }) {
                        HStack {
                            Text("None")
                            Spacer()
                            if !hasDate {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .font(.system(size: 14))
                        .foregroundColor(ColorPalette.textPrimary)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        date = Date()
                        hasDate = true
                        showPicker = false
                    }) {
                        HStack {
                            Text("Today")
                            Spacer()
                            if hasDate && Calendar.current.isDateInToday(date) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .font(.system(size: 14))
                        .foregroundColor(ColorPalette.textPrimary)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
                        hasDate = true
                        showPicker = false
                    }) {
                        HStack {
                            Text("Tomorrow")
                            Spacer()
                        }
                        .font(.system(size: 14))
                        .foregroundColor(ColorPalette.textPrimary)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                    
                    Divider()
                    
                    DatePicker(
                        "Select Date",
                        selection: $date,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .onChange(of: date) { oldValue, newValue in
                        hasDate = true
                    }
                }
                .padding(16)
                .frame(width: 300)
            }
        }
        .foregroundStyle(.secondary)
    }
}

struct PriorityPickerRow: View {
    let label: String
    @Binding var priority: TaskPriority
    @Binding var showPicker: Bool
    
    private var priorityText: String {
        switch priority {
        case .high: return "HIGH"
        case .medium: return "MED"
        case .low: return "LOW"
        }
    }
    
    private var priorityColor: Color {
        switch priority {
        case .high: return .orange
        case .medium: return .blue
        case .low: return .secondary
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle").frame(width: 20)
            Text(label).font(.system(size: 14))
            Spacer()
            Button(action: {
                showPicker.toggle()
            }) {
                Text(priorityText)
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(priorityColor.opacity(0.1))
                    .foregroundStyle(priorityColor)
                    .cornerRadius(4)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showPicker, arrowEdge: .bottom) {
                VStack(spacing: 8) {
                    ForEach([TaskPriority.low, .medium, .high], id: \.self) { p in
                        Button(action: {
                            priority = p
                            showPicker = false
                        }) {
                            HStack {
                                Text(p == .high ? "HIGH" : p == .medium ? "MED" : "LOW")
                                Spacer()
                                if priority == p {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                            .font(.system(size: 14))
                            .foregroundColor(ColorPalette.textPrimary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(priority == p ? Color.blue.opacity(0.1) : Color.clear)
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(12)
                .frame(width: 200)
            }
        }
        .foregroundStyle(.secondary)
    }
}
