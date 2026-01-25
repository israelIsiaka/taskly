//
//  Subtask.swift
//  taskly
//
//  Subtask model - Child tasks for TaskItem
//

import Foundation
import SwiftData

/// Subtask model - Child tasks that belong to a parent TaskItem
@Model
final class Subtask {
    var id: UUID = UUID()
    var title: String = ""
    var isCompleted: Bool = false
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    // Relationship to parent TaskItem (inverse defined on TaskItem)
    var parentTask: TaskItem?
    
    init(
        id: UUID = UUID(),
        title: String = "",
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        parentTask: TaskItem? = nil
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.parentTask = parentTask
    }
    
    /// Update the updatedAt timestamp
    func touch() {
        updatedAt = Date()
    }
}

