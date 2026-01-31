//
//  SFSymbols.swift
//  taskly
//
//  SF Symbols helper - centralized icon management
//  Based on design prompt requirements
//

import SwiftUI

/// Centralized SF Symbols for the app
/// Makes it easy to update icons across the app and ensures consistency
enum SFSymbols {
    // MARK: - Navigation Icons
    
    /// Pending view icon
    static let pending = "tray"
    
    /// Today view icon
    static let today = "calendar"
    
    /// Projects view icon
    static let projects = "folder"
    
    /// Completed view icon
    static let completed = "checkmark.circle"
    
    /// Settings icon
    static let settings = "gearshape"
    
    // MARK: - Task Actions
    
    /// Add task icon
    static let addTask = "plus.circle.fill"
    
    /// Add subtask icon
    static let addSubtask = "arrow.turn.down.right"
    
    /// Delete task icon
    static let delete = "trash"
    
    /// Flag task icon
    static let flag = "flag"
    
    /// Unflag task icon
    static let unflag = "flag.slash"
    
    /// Edit icon
    static let edit = "pencil"
    
    /// Duplicate icon
    static let duplicate = "doc.on.doc"
    
    // MARK: - Checkboxes
    
    /// Empty checkbox
    static let checkboxEmpty = "circle"
    
    /// Completed checkbox
    static let checkboxFilled = "checkmark.circle.fill"
    
    // MARK: - Navigation Controls
    
    /// Previous/Back chevron
    static let chevronLeft = "chevron.left"
    
    /// Next/Forward chevron
    static let chevronRight = "chevron.right"
    
    // MARK: - Project Icons
    
    /// Add project icon
    static let addProject = "plus"
    
    /// Project folder icon
    static let project = "folder"
    
    /// Project with color dot
    static let projectFill = "folder.fill"
    
    // MARK: - Search & Filter
    
    /// Search icon
    static let search = "magnifyingglass"
    
    /// Filter icon
    static let filter = "line.3.horizontal.decrease.circle"
    
    // MARK: - Calendar
    
    /// Calendar icon
    static let calendar = "calendar"
    
    /// Calendar with day indicator
    static let calendarBadge = "calendar.badge.clock"
    
    // MARK: - Status Indicators
    
    /// Priority high
    static let priorityHigh = "exclamationmark.triangle.fill"
    
    /// Priority medium
    static let priorityMedium = "minus.circle.fill"
    
    /// Priority low
    static let priorityLow = "arrow.down.circle.fill"
    
    // MARK: - Actions
    
    /// Save/Checkmark
    static let checkmark = "checkmark"
    
    /// Cancel/Close
    static let xmark = "xmark"
    
    /// More options (three dots)
    static let ellipsis = "ellipsis"
    
    /// More options circle
    static let ellipsisCircle = "ellipsis.circle"
    
    // MARK: - Empty States
    
    /// Empty pending
    static let emptyPending = "tray"
    
    /// Empty calendar
    static let emptyCalendar = "calendar.badge.exclamationmark"
    
    /// Empty flag
    static let emptyFlag = "flag.slash"
    
    /// Success/Complete illustration
    static let success = "checkmark.circle.fill"
    
    // MARK: - Helper Methods
    
    /// Get icon for a specific view type
    static func icon(for viewType: ViewType) -> String {
        switch viewType {
        case .pending: return pending
        case .today: return today
        case .projects: return projects
        case .completed: return completed
        case .settings: return settings
        case .calendar: return calendar
        }
    }
    
    /// View types for icon mapping
    enum ViewType {
        case pending
        case today
        case projects
        case completed
        case settings
        case calendar
    }
}

// MARK: - SwiftUI Image Extension

extension Image {
    /// Create an Image from an SF Symbol name
    /// Usage: Image(sfSymbol: .pending)
    init(sfSymbol: String) {
        self.init(systemName: sfSymbol)
    }
    
    /// Create an Image from SFSymbols enum
    /// Usage: Image(sfSymbol: SFSymbols.pending)
    init(_ symbol: String) {
        self.init(systemName: symbol)
    }
}

// MARK: - Convenience View Modifiers

extension View {
    /// Apply SF Symbol icon styling
    func sfSymbolStyle(size: CGFloat = 16, weight: Font.Weight = .regular) -> some View {
        self
            .font(.system(size: size, weight: weight))
            .imageScale(.medium)
    }
}
