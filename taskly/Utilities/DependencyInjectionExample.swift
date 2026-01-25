//
//  DependencyInjectionExample.swift
//  taskly
//
//  Examples demonstrating dependency injection usage
//  This file can be deleted once you understand the pattern
//

import SwiftUI

// MARK: - Example 1: Using @Injected Property Wrapper

class ExampleService {
    func doSomething() {
        print("Service doing something")
    }
}

class ExampleViewModelWithDI: BaseViewModel {
    // Inject dependency using property wrapper
    @Injected private var service: ExampleService
    
    func performAction() {
        service.doSomething()
    }
}

// MARK: - Example 2: Manual Dependency Injection

class ExampleViewModelManual: BaseViewModel {
    private let service: ExampleService
    
    init(service: ExampleService = DependencyContainer.shared.resolve()) {
        self.service = service
        super.init()
    }
    
    func performAction() {
        service.doSomething()
    }
}

// MARK: - Example 3: Using Environment in SwiftUI

struct ExampleViewWithEnvironment: View {
    @Environment(\.dependencies) private var container
    
    var body: some View {
        VStack {
            Text("Dependency Injection Example")
            
            Button("Resolve Service") {
                let service: ExampleService = container.resolve()
                service.doSomething()
            }
        }
    }
}

// MARK: - Example 4: Registering Dependencies

extension DependencyContainer {
    /// Example of how to register dependencies
    func registerExampleDependencies() {
        // Register as singleton (shared instance)
        registerSingleton(ExampleService.self) {
            ExampleService()
        }
        
        // Register as factory (new instance each time)
        register(ExampleService.self) {
            ExampleService()
        }
        
        // Register specific instance
        let sharedService = ExampleService()
        register(ExampleService.self, instance: sharedService)
    }
}

// MARK: - Usage in App

/*
 In your tasklyApp.swift, you can register dependencies:
 
 @main
 struct tasklyApp: App {
     init() {
         // Register dependencies
         DependencyContainer.shared.registerSingleton(TaskServiceProtocol.self) {
             TaskService()
         }
         
         DependencyContainer.shared.registerSingleton(ProjectServiceProtocol.self) {
             ProjectService()
         }
     }
 }
 
 Then in ViewModels:
 
 class TodayViewModel: BaseViewModel {
     @Injected private var taskService: TaskServiceProtocol
     
     func loadTasks() {
         Task {
             let tasks = try await taskService.fetchTasks()
             // Update UI
         }
     }
 }
 */
