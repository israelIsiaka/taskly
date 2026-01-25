//
//  ViewModelFactory.swift
//  taskly
//
//  Factory for creating ViewModels (simple dependency injection)
//

import Foundation

/// Protocol for ViewModel factories
protocol ViewModelFactoryProtocol {
    func makeTodayViewModel() -> TodayViewModel
    func makeInboxViewModel() -> InboxViewModel
    func makeTaskViewModel() -> TaskViewModel
    func makeProjectViewModel() -> ProjectViewModel
    // Add more factory methods as needed
}

/// Default ViewModel factory implementation
class ViewModelFactory: ViewModelFactoryProtocol {
    // Dependencies can be injected here
    private var container: DependencyContainer?
    
    init(container: DependencyContainer? = nil) {
        self.container = container
    }
    
    /// Get container, lazily accessing shared if needed (avoids circular dependency)
    private var resolvedContainer: DependencyContainer {
        if let container = container {
            return container
        }
        return DependencyContainer.shared
    }
    
    func makeTodayViewModel() -> TodayViewModel {
        // Resolve any dependencies from container if needed
        // Example: let taskService = resolvedContainer.resolve(TaskServiceProtocol.self)
        return TodayViewModel()
    }
    
    func makeInboxViewModel() -> InboxViewModel {
        return InboxViewModel()
    }
    
    func makeTaskViewModel() -> TaskViewModel {
        return TaskViewModel()
    }
    
    func makeProjectViewModel() -> ProjectViewModel {
        return ProjectViewModel()
    }
}

// MARK: - Placeholder ViewModels (to be implemented)

@MainActor
class TodayViewModel: BaseViewModel {
    // To be implemented
}

@MainActor
class InboxViewModel: BaseViewModel {
    // To be implemented
}

@MainActor
class TaskViewModel: BaseViewModel {
    // To be implemented
}

@MainActor
class ProjectViewModel: BaseViewModel {
    // To be implemented
}
