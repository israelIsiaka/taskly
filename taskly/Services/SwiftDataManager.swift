//
//  SwiftDataManager.swift
//  taskly
//
//  SwiftData manager/service class for data operations
//

import Foundation
import SwiftData

/// SwiftData manager for handling data operations
@MainActor
class SwiftDataManager {
    static let shared = SwiftDataManager()
    
    private var modelContext: ModelContext?
    
    private init() {}
    
    /// Set the model context (called from app initialization)
    func setContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    /// Get the current model context
    var context: ModelContext {
        guard let context = modelContext else {
            fatalError("ModelContext not set. Call setContext() first.")
        }
        return context
    }
    
    // MARK: - Save Operations
    
    /// Save the current context
    func save() throws {
        try context.save()
    }
    
    /// Save the context asynchronously
    func saveAsync() {
        Task { @MainActor in
            try? context.save()
        }
    }
    
    // MARK: - Fetch Operations
    
    /// Fetch all items of a type
    func fetch<T: PersistentModel>(_ type: T.Type, predicate: Predicate<T>? = nil, sortDescriptors: [SortDescriptor<T>] = []) throws -> [T] {
        var descriptor = FetchDescriptor<T>(predicate: predicate, sortBy: sortDescriptors)
        return try context.fetch(descriptor)
    }
    
    /// Fetch a single item by ID
    func fetch<T: PersistentModel>(_ type: T.Type, id: UUID) throws -> T? {
        // Build a type-specific predicate to satisfy #Predicate single-expression requirement
        if type == TaskItem.self {
            let predicate = #Predicate<TaskItem> { $0.id == id }
            let results = try fetch(TaskItem.self, predicate: predicate)
            return results.first as? T
        } else if type == Project.self {
            let predicate = #Predicate<Project> { $0.id == id }
            let results = try fetch(Project.self, predicate: predicate)
            return results.first as? T
        } else {
            // Unsupported type for ID-based fetch; return nil or consider throwing
            return nil
        }
    }
    
    // MARK: - Delete Operations
    
    /// Delete an item
    func delete<T: PersistentModel>(_ item: T) {
        context.delete(item)
    }
    
    /// Delete multiple items
    func delete<T: PersistentModel>(_ items: [T]) {
        for item in items {
            context.delete(item)
        }
    }
    
    // MARK: - Insert Operations
    
    /// Insert an item
    func insert<T: PersistentModel>(_ item: T) {
        context.insert(item)
    }
    
    /// Insert multiple items
    func insert<T: PersistentModel>(_ items: [T]) {
        for item in items {
            context.insert(item)
        }
    }
}

