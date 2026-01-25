//
//  TaskItem.swift
//  taskly
//
//  TaskItem model - Complete SwiftData model
//

import Foundation
import SwiftData

/// Task priority levels
enum TaskPriority: Int, Codable {
    case low = 0
    case medium = 1
    case high = 2
}

/// TaskItem model - Complete implementation
@Model
final class TaskItem {
    var id: UUID = UUID()
    var title: String = ""
    var taskDescription: String = ""
    var dueDate: Date?
    var priority: Int = TaskPriority.medium.rawValue
    var isFlagged: Bool = false
    var isCompleted: Bool = false
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    // Relationships
    var project: Project?
    
    var subtasks: [Subtask]? = []
    
    var tags: [Tag]? = []
    
    init(
        id: UUID = UUID(),
        title: String = "",
        taskDescription: String = "",
        dueDate: Date? = nil,
        priority: TaskPriority = .medium,
        isFlagged: Bool = false,
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        project: Project? = nil
    ) {
        self.id = id
        self.title = title
        self.taskDescription = taskDescription
        self.dueDate = dueDate
        self.priority = priority.rawValue
        self.isFlagged = isFlagged
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.project = project
    }
    
    /// Computed property for priority enum
    var priorityLevel: TaskPriority {
        get {
            TaskPriority(rawValue: priority) ?? .medium
        }
        set {
            priority = newValue.rawValue
        }
    }
    
    /// Update the updatedAt timestamp
    func touch() {
        updatedAt = Date()
    }
}
