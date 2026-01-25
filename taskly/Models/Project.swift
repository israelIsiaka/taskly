//
//  Project.swift
//  taskly
//
//  Project model - Complete SwiftData model
//

import Foundation
import SwiftData
import SwiftUI

/// Project model - Complete implementation
@Model
final class Project {
    var id: UUID = UUID()
    var name: String = ""
    var color: String = "#007AFF" // Default to primary blue
    var icon: String = "folder" // SF Symbol name
    var projectDescription: String = ""
    var createdAt: Date = Date()
    
    // Relationships
    var tasks: [TaskItem]? = []
    
    init(
        id: UUID = UUID(),
        name: String = "",
        color: String = "#007AFF",
        icon: String = "folder",
        projectDescription: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.icon = icon
        self.projectDescription = projectDescription
        self.createdAt = createdAt
    }
    
    /// Computed property for SwiftUI Color
    var colorValue: Color {
        Color(hex: color) ?? ColorPalette.primaryAction
    }
    
    /// Task count
    var taskCount: Int {
        tasks?.count ?? 0
    }
    
    /// Completed task count
    var completedTaskCount: Int {
        tasks?.filter { $0.isCompleted }.count ?? 0
    }
    
    /// Completion percentage
    var completionPercentage: Double {
        guard taskCount > 0 else { return 0 }
        return Double(completedTaskCount) / Double(taskCount)
    }
}
