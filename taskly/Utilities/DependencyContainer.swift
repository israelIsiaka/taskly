//
//  DependencyContainer.swift
//  taskly
//
//  Dependency Injection Container for managing app dependencies
//

import Foundation
import SwiftData
import SwiftUI

/// Protocol for dependency registration
protocol DependencyRegistering {
    func register<T>(_ type: T.Type, factory: @escaping () -> T)
    func register<T>(_ type: T.Type, instance: T)
}

/// Protocol for dependency resolution
protocol DependencyResolving {
    func resolve<T>(_ type: T.Type) -> T
    func resolveOptional<T>(_ type: T.Type) -> T?
}

/// Dependency injection container
class DependencyContainer: DependencyRegistering, DependencyResolving {
    static let shared = DependencyContainer()
    
    private var factories: [String: () -> Any] = [:]
    private var singletons: [String: Any] = [:]
    
    private init() {
        registerDefaultDependencies()
    }
    
    // MARK: - Registration
    
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        factories[key] = factory
    }
    
    func register<T>(_ type: T.Type, instance: T) {
        let key = String(describing: type)
        singletons[key] = instance
    }
    
    func registerSingleton<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        if singletons[key] == nil {
            singletons[key] = factory()
        }
    }
    
    // MARK: - Resolution
    
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        
        // Check for singleton first
        if let singleton = singletons[key] as? T {
            return singleton
        }
        
        // Check for factory
        if let factory = factories[key] {
            if let instance = factory() as? T {
                return instance
            }
        }
        
        fatalError("Dependency '\(key)' not registered")
    }
    
    func resolveOptional<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        
        // Check for singleton first
        if let singleton = singletons[key] as? T {
            return singleton
        }
        
        // Check for factory
        if let factory = factories[key] {
            return factory() as? T
        }
        
        return nil
    }
    
    // MARK: - Default Dependencies
    
    private func registerDefaultDependencies() {
        // Don't register ViewModelFactory here to avoid circular dependency
        // It will be registered later if needed, or accessed directly
        // ViewModelFactory can be created without the container initially
        
        // Services will be registered here as they're created
        // Example when services are implemented:
        // registerSingleton(TaskServiceProtocol.self) { TaskService() }
        // registerSingleton(ProjectServiceProtocol.self) { ProjectService() }
        // registerSingleton(SyncServiceProtocol.self) { CloudKitSyncService() }
    }
    
    // MARK: - Cleanup
    
    func reset() {
        factories.removeAll()
        singletons.removeAll()
        registerDefaultDependencies()
    }
}

// MARK: - Convenience Extensions

extension DependencyContainer {
    /// Resolve dependency with type inference
    func resolve<T>() -> T {
        return resolve(T.self)
    }
    
    /// Resolve optional dependency with type inference
    func resolveOptional<T>() -> T? {
        return resolveOptional(T.self)
    }
}

// MARK: - Property Wrapper for Dependency Injection

@propertyWrapper
struct Injected<T> {
    private var value: T?
    private let container: DependencyContainer
    
    var wrappedValue: T {
        mutating get {
            if value == nil {
                value = container.resolve(T.self)
            }
            return value!
        }
    }
    
    init(container: DependencyContainer = .shared) {
        self.container = container
    }
}

// MARK: - Environment Key for SwiftUI

struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue = DependencyContainer.shared
}

extension EnvironmentValues {
    var dependencies: DependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}
