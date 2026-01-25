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
    private let container: DependencyContainer
    
    init(container: DependencyContainer = .shared) {
        self.container = container
    }
    
    func makeTodayViewModel() -> TodayViewModel {
        // Resolve any dependencies from container if needed
        // Example: let taskService = container.resolve(TaskServiceProtocol.self)
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
