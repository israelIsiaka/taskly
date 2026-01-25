# Dependency Injection Guide

## Overview

The app uses a lightweight dependency injection container to manage dependencies and improve testability.

## DependencyContainer

The `DependencyContainer` is a singleton that manages all app dependencies. It supports:
- **Singleton registration** - One instance shared across the app
- **Factory registration** - New instance created each time
- **Instance registration** - Register a specific instance

## Usage Patterns

### 1. Registering Dependencies

Register dependencies in your app's initialization:

```swift
@main
struct tasklyApp: App {
    init() {
        // Register services as singletons
        DependencyContainer.shared.registerSingleton(TaskServiceProtocol.self) {
            TaskService()
        }
        
        DependencyContainer.shared.registerSingleton(ProjectServiceProtocol.self) {
            ProjectService()
        }
    }
}
```

### 2. Using @Injected Property Wrapper

The easiest way to inject dependencies in ViewModels:

```swift
@MainActor
class TodayViewModel: BaseViewModel {
    @Injected private var taskService: TaskServiceProtocol
    
    func loadTasks() {
        Task {
            let tasks = try await taskService.fetchTasks()
            // Update UI
        }
    }
}
```

### 3. Manual Resolution

Resolve dependencies manually when needed:

```swift
let service: TaskServiceProtocol = DependencyContainer.shared.resolve()
```

### 4. Optional Resolution

For optional dependencies:

```swift
if let service = DependencyContainer.shared.resolveOptional(TaskServiceProtocol.self) {
    // Use service
}
```

### 5. Using Environment in SwiftUI

Access the container via environment:

```swift
struct MyView: View {
    @Environment(\.dependencies) private var container
    
    var body: some View {
        // Use container.resolve() if needed
    }
}
```

## Registration Types

### Singleton
Creates one instance that's shared:

```swift
container.registerSingleton(MyService.self) {
    MyService()
}
```

### Factory
Creates a new instance each time:

```swift
container.register(MyService.self) {
    MyService()
}
```

### Instance
Register a specific instance:

```swift
let myService = MyService()
container.register(MyService.self, instance: myService)
```

## Best Practices

1. **Register in App init** - Set up all dependencies when the app starts
2. **Use protocols** - Register protocols, not concrete types for testability
3. **Singletons for services** - Most services should be singletons
4. **Factories for ViewModels** - ViewModels are usually created fresh
5. **Test with mocks** - Use the container to inject mock services in tests

## Testing

In tests, you can replace dependencies:

```swift
func testExample() {
    let container = DependencyContainer()
    container.register(TaskServiceProtocol.self, instance: MockTaskService())
    
    let viewModel = TodayViewModel()
    // Test with mock service
}
```

## Example: Complete Flow

```swift
// 1. Define protocol
protocol DataServiceProtocol {
    func fetchData() async throws -> [Data]
}

// 2. Implement service
class DataService: DataServiceProtocol {
    func fetchData() async throws -> [Data] {
        // Implementation
    }
}

// 3. Register in app
DependencyContainer.shared.registerSingleton(DataServiceProtocol.self) {
    DataService()
}

// 4. Use in ViewModel
class MyViewModel: BaseViewModel {
    @Injected private var dataService: DataServiceProtocol
    
    func load() {
        Task {
            let data = try await dataService.fetchData()
            // Update state
        }
    }
}
```
