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
    @State private var subtasks: [String] = []
    @State private var editingSubtaskIndex: Int? = nil
    @State private var editingSubtaskText = ""
    @State private var newSubtaskText = ""
    @State private var showNewSubtaskField = false
    @State private var status = "In Progress"
    @State private var priority = "MED"
    @State private var dueDate: Date = Date()
    @State private var showDatePicker = false
    @State private var isFlagged = false
    @State private var selectedProject: Project? = nil
    @State private var showValidationError = false
    @State private var isCreating = false
    @Query(sort: \Project.name) private var projects: [Project]
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            HStack {
                Text("New Task")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(ColorPalette.textPrimary)
                Spacer()
                Button(action: { 
                    resetForm()
                    isPresented = false 
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(ColorPalette.textTertiary)
                }
                .buttonStyle(.plain)
            }
            
            // Task Title Input
            VStack(alignment: .leading, spacing: 8) {
                Text("TASK TITLE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(ColorPalette.textTertiary)
                
                TextField("What needs to be done?", text: $taskTitle)
                    .font(.system(size: 22, weight: .semibold))
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
                
                TextField("Add description or notes...", text: $taskNotes)
                    .font(.system(size: 14))
                    .textFieldStyle(.plain)
                    .foregroundColor(ColorPalette.textSecondary)
                    .padding(.top, 4)
            }
            
            // Subtasks Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("SUBTASKS")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(ColorPalette.textTertiary)
                    Spacer()
                    Button(action: {
                        showNewSubtaskField = true
                    }) {
                        Text("+ Add Subtask")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.purple)
                    }
                    .buttonStyle(.plain)
                }
                
                // New subtask input field
                if showNewSubtaskField {
                    HStack(spacing: 12) {
                        Image(systemName: "circle")
                            .foregroundStyle(ColorPalette.textTertiary)
                        TextField("New subtask...", text: $newSubtaskText)
                            .font(.system(size: 14))
                            .textFieldStyle(.plain)
                            .foregroundColor(ColorPalette.textPrimary)
                            .onSubmit {
                                addSubtask()
                            }
                            .onAppear {
                                // Auto-focus the text field
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    // Focus will be handled by the TextField
                                }
                            }
                        Button(action: addSubtask) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.purple)
                        }
                        .buttonStyle(.plain)
                        Button(action: {
                            showNewSubtaskField = false
                            newSubtaskText = ""
                        }) {
                            Image(systemName: "xmark")
                                .foregroundStyle(ColorPalette.textSecondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Subtasks list - editable
                ForEach(Array(subtasks.enumerated()), id: \.offset) { index, subtask in
                    HStack(spacing: 12) {
                        Image(systemName: "circle")
                            .foregroundStyle(ColorPalette.textTertiary)
                        
                        if editingSubtaskIndex == index {
                            TextField("Subtask", text: $editingSubtaskText)
                                .font(.system(size: 14))
                                .textFieldStyle(.plain)
                                .foregroundColor(ColorPalette.textPrimary)
                                .onSubmit {
                                    saveSubtaskEdit(at: index)
                                }
                                .onExitCommand {
                                    cancelSubtaskEdit()
                                }
                        } else {
                            Text(subtask)
                                .font(.system(size: 14))
                                .foregroundStyle(ColorPalette.textPrimary)
                                .onTapGesture {
                                    startEditingSubtask(at: index, text: subtask)
                                }
                        }
                        
                        Spacer()
                        
                        if editingSubtaskIndex == index {
                            Button(action: {
                                saveSubtaskEdit(at: index)
                            }) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.purple)
                            }
                            .buttonStyle(.plain)
                            Button(action: {
                                cancelSubtaskEdit()
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundStyle(ColorPalette.textSecondary)
                            }
                            .buttonStyle(.plain)
                        } else {
                            Button(action: {
                                removeSubtask(at: index)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(ColorPalette.textTertiary.opacity(0.5))
                                    .font(.system(size: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            
            // Bottom Grid (Date, Project, Priority, Status)
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    DateTimePickerField(selectedDate: $dueDate, showPicker: $showDatePicker)
                    ProjectPickerField(selectedProject: $selectedProject, projects: projects)
                }
                
                HStack(spacing: 16) {
                    PrioritySegmentedPicker(selection: $priority)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("FLAGGED")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(ColorPalette.textTertiary)
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
            }
            
            // Actions
            HStack(spacing: 16) {
                Spacer()
                Button("Cancel") { 
                    resetForm()
                    isPresented = false 
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(ColorPalette.textSecondary)
                .disabled(isCreating)
                
                Button("Add Task") { 
                    createTask()
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [Color.purple, Color(red: 0.5, green: 0, blue: 1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: .purple.opacity(0.3), radius: 10, y: 5)
                .disabled(isCreating || taskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(isCreating || taskTitle.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
            }
        }
        .padding(32)
        .frame(width: 520)
        .background(ColorPalette.background)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.5 : 0.15), radius: 50, x: 0, y: 25)
        .onChange(of: taskTitle) { oldValue, newValue in
            if showValidationError && !newValue.trimmingCharacters(in: .whitespaces).isEmpty {
                showValidationError = false
            }
        }
    }
    
    // MARK: - Computed Properties
    
    // MARK: - Helper Methods
    
    private func addSubtask() {
        let trimmed = newSubtaskText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        subtasks.append(trimmed)
        newSubtaskText = ""
        showNewSubtaskField = false
    }
    
    private func removeSubtask(at index: Int) {
        guard index < subtasks.count else { return }
        subtasks.remove(at: index)
    }
    
    private func startEditingSubtask(at index: Int, text: String) {
        editingSubtaskIndex = index
        editingSubtaskText = text
    }
    
    private func saveSubtaskEdit(at index: Int) {
        let trimmed = editingSubtaskText.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty && index < subtasks.count {
            subtasks[index] = trimmed
        } else if trimmed.isEmpty && index < subtasks.count {
            // Remove if empty
            subtasks.remove(at: index)
        }
        cancelSubtaskEdit()
    }
    
    private func cancelSubtaskEdit() {
        editingSubtaskIndex = nil
        editingSubtaskText = ""
    }
    
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
            switch priority.uppercased() {
            case "HIGH": return .high
            case "LOW": return .low
            default: return .medium
            }
        }()
        
        // Create task
        let task = TaskItem(
            title: trimmedTitle,
            taskDescription: taskNotes,
            dueDate: dueDate,
            priority: priorityEnum,
            isFlagged: isFlagged,
            project: selectedProject
        )
        
        // Create and attach subtasks
        for subtaskTitle in subtasks {
            let subtask = Subtask(
                title: subtaskTitle,
                isCompleted: false, // Subtasks start as incomplete
                parentTask: task
            )
            modelContext.insert(subtask)
        }
        
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
        subtasks = []
        editingSubtaskIndex = nil
        editingSubtaskText = ""
        newSubtaskText = ""
        showNewSubtaskField = false
        status = "In Progress"
        priority = "MED"
        dueDate = Date()
        showDatePicker = false
        isFlagged = false
        selectedProject = nil
        showValidationError = false
        isCreating = false
    }
}

// Project picker field for New Task modal
struct ProjectPickerField: View {
    @Binding var selectedProject: Project?
    let projects: [Project]

    private var displayValue: String {
        selectedProject?.name ?? "None"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PROJECT")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(ColorPalette.textTertiary)
            Menu {
                Button("None") {
                    selectedProject = nil
                }
                ForEach(projects, id: \.id) { project in
                    Button(project.name) {
                        selectedProject = project
                    }
                }
            } label: {
                HStack {
                    Text(displayValue)
                        .foregroundColor(ColorPalette.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundStyle(ColorPalette.textSecondary)
                }
                .font(.system(size: 14))
                .padding(10)
                .background(ColorPalette.surface.opacity(0.5))
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
    }
}

// Helper for the small input boxes
struct ModalInputPicker: View {
    let label: String
    let value: String
    var icon: String?
    var iconColor: Color?
    var hasChevron: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(ColorPalette.textTertiary)
            HStack {
                if let icon = icon { 
                    Image(systemName: icon)
                        .foregroundStyle(iconColor ?? ColorPalette.textSecondary)
                        .font(.system(size: 12))
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

// Date and time picker field (required, min = start of today, no past dates)
struct DateTimePickerField: View {
    @Binding var selectedDate: Date
    @Binding var showPicker: Bool
    @State private var tempDate: Date = Date()

    private var minDate: Date {
        Calendar.current.startOfDay(for: Date())
    }

    private var displayText: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df.string(from: selectedDate)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DUE DATE & TIME")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(ColorPalette.textTertiary)

            Button(action: {
                tempDate = max(selectedDate, minDate)
                showPicker.toggle()
            }) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(ColorPalette.textSecondary)
                        .font(.system(size: 12))
                    Text(displayText)
                        .foregroundColor(ColorPalette.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundStyle(ColorPalette.textSecondary)
                }
                .font(.system(size: 14))
                .padding(10)
                .background(ColorPalette.surface.opacity(0.5))
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showPicker, arrowEdge: .bottom) {
                VStack(alignment: .leading, spacing: 12) {
                    DatePicker(
                        "Date & time",
                        selection: Binding(
                            get: { tempDate },
                            set: { tempDate = $0 }
                        ),
                        in: minDate...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()

                    HStack {
                        Spacer()
                        Button("Done") {
                            selectedDate = max(tempDate, minDate)
                            showPicker = false
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(16)
                .frame(width: 320)
            }
        }
    }
}

// Date Picker Field (optional, for use elsewhere)
struct DatePickerField: View {
    @Binding var selectedDate: Date?
    @Binding var showPicker: Bool
    @State private var tempDate: Date = Date()
    
    private var displayText: String {
        guard let date = selectedDate else { return "None" }
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DUE DATE")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(ColorPalette.textTertiary)
            
            ZStack(alignment: .leading) {
                Button(action: {
                    if selectedDate != nil {
                        tempDate = selectedDate!
                    }
                    showPicker.toggle()
                }) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(ColorPalette.textSecondary)
                            .font(.system(size: 12))
                        Text(displayText)
                            .foregroundColor(ColorPalette.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                            .foregroundStyle(ColorPalette.textSecondary)
                    }
                    .font(.system(size: 14))
                    .padding(10)
                    .background(ColorPalette.surface.opacity(0.5))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showPicker, arrowEdge: .bottom) {
                    VStack(alignment: .leading, spacing: 12) {
                        // Quick options
                        VStack(alignment: .leading, spacing: 8) {
                            Button(action: {
                                selectedDate = nil
                                showPicker = false
                            }) {
                                HStack {
                                    Text("None")
                                    Spacer()
                                    if selectedDate == nil {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(ColorPalette.primaryAction)
                                    }
                                }
                                .font(.system(size: 14))
                                .foregroundColor(ColorPalette.textPrimary)
                                .padding(.vertical, 6)
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: {
                                selectedDate = Date()
                                showPicker = false
                            }) {
                                HStack {
                                    Text("Today")
                                    Spacer()
                                    if Calendar.current.isDate(selectedDate ?? Date.distantFuture, inSameDayAs: Date()) {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(ColorPalette.primaryAction)
                                    }
                                }
                                .font(.system(size: 14))
                                .foregroundColor(ColorPalette.textPrimary)
                                .padding(.vertical, 6)
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: {
                                selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
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
                        }
                        
                        Divider()
                        
                        // Date picker
                        DatePicker(
                            "Select Date",
                            selection: Binding(
                                get: { tempDate },
                                set: { tempDate = $0 }
                            ),
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .onChange(of: tempDate) { oldValue, newValue in
                            selectedDate = newValue
                        }
                        
                        HStack {
                            Spacer()
                            Button("Done") {
                                selectedDate = tempDate
                                showPicker = false
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(16)
                    .frame(width: 300)
                }
            }
        }
    }
}

// Priority Segmented Picker
struct PrioritySegmentedPicker: View {
    @Binding var selection: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PRIORITY")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(ColorPalette.textTertiary)
            
            HStack(spacing: 4) {
                ForEach(["LOW", "MED", "HIGH"], id: \.self) { p in
                    Text(p)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(selection == p ? ColorPalette.textPrimary : ColorPalette.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            ZStack {
                                // Selected state with depth
                                if selection == p {
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
                                .stroke(selection == p ? Color.white.opacity(colorScheme == .dark ? 0.15 : 0.3) : Color.clear, lineWidth: 0.5)
                        )
                        .onTapGesture { selection = p }
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
    }
}
