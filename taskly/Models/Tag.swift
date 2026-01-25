//
//  Tag.swift
//  taskly
//
//  Tag model - Labels/tags for tasks
//

import Foundation
import SwiftData
import SwiftUI

/// Tag model - Labels that can be assigned to tasks
@Model
final class Tag {
    var id: UUID = UUID()
    var name: String = ""
    var color: String = "#007AFF" // Default to primary blue
    var createdAt: Date = Date()
    
    // Relationship to tasks
    var tasks: [TaskItem]? = []
    
    init(
        id: UUID = UUID(),
        name: String = "",
        color: String = "#007AFF",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.createdAt = createdAt
    }
    
    /// Computed property for SwiftUI Color
    var colorValue: Color {
        Color(hex: color) ?? ColorPalette.primaryAction
    }
}
