import SwiftUI
struct TaskCard: View {
    let task: TaskItem
    
    // Using your established helper for priority styling
    private var priorityColor: Color {
        switch task.priorityLevel {
        case .high: return .orange
        case .medium: return .blue
        case .low: return .secondary
        }
    }
    
    private var priorityText: String {
        switch task.priorityLevel {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) { // Increased spacing for subtask clarity
            HStack(alignment: .top, spacing: 14) {
                // Main Task Checkbox
                Button(action: { /* Toggle Task */ }) {
                    Circle()
                        .strokeBorder(task.isCompleted ? Color.purple : .secondary.opacity(0.3), lineWidth: 2)
                        .background(task.isCompleted ? Color.purple : .clear)
                        .frame(width: 20, height: 20)
                        .overlay(
                            task.isCompleted ? 
                            Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundColor(.white) : nil
                        )
                }
                .buttonStyle(.plain)
                
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
                    
                    // MARK: - Subtasks Section
                    if let subtasks = task.subtasks, !subtasks.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(subtasks) { subtask in
                                HStack(spacing: 10) {
                                    // Subtask Toggle (smaller than main checkbox)
                                    Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 14))
                                        .foregroundColor(subtask.isCompleted ? .purple : .secondary.opacity(0.5))
                                    
                                    Text(subtask.title)
                                        .font(.system(size: 13))
                                        .strikethrough(subtask.isCompleted)
                                        .foregroundColor(subtask.isCompleted ? .secondary : .primary.opacity(0.8))
                                }
                            }
                        }
                        .padding(.top, 8)
                        .padding(.leading, 2) // Slight offset for visual hierarchy
                    }
                }
                
                Spacer()
                
                // Priority Tag matching image_7223cb.jpg
                if !task.isCompleted {
                    Text("\(priorityText) Priority")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(priorityColor.opacity(0.1))
                        .foregroundColor(priorityColor)
                        .cornerRadius(6)
                }
            }
        }
        .padding(20)
        .glassCardStyle() // Reusing your custom glass modifier
    }
}
