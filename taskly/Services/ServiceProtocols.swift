//
//  ServiceProtocols.swift
//  taskly
//
//  Service protocols for dependency injection
//

import Foundation
import SwiftData

/// Protocol for task-related operations
/// Note: Using taskly.Task to disambiguate from Swift's concurrency Task type
protocol TaskServiceProtocol {
    func fetchTasks() async throws -> [taskly.TaskItem]
    func createTask(_ task: taskly.TaskItem) async throws
    func updateTask(_ task: taskly.TaskItem) async throws
    func deleteTask(_ task: taskly.TaskItem) async throws
}

/// Protocol for project-related operations
protocol ProjectServiceProtocol {
    func fetchProjects() async throws -> [Project]
    func createProject(_ project: Project) async throws
    func updateProject(_ project: Project) async throws
    func deleteProject(_ project: Project) async throws
}

/// Protocol for sync operations
protocol SyncServiceProtocol {
    func sync() async throws
    func getSyncStatus() -> SyncStatus
}

/// Sync status enum
enum SyncStatus {
    case idle
    case syncing
    case success
    case error(String)
}

// MARK: - Placeholder implementations (to be created later)

// These will be implemented in actual service classes:
// - TaskService: TaskServiceProtocol
// - ProjectService: ProjectServiceProtocol
// - CloudKitSyncService: SyncServiceProtocol
