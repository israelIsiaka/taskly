# MVVM Architecture Guide

## Overview

This project uses the **Model-View-ViewModel (MVVM)** architecture pattern to separate concerns and make the codebase more maintainable.

## Architecture Components

### 1. Models (`Models/`)
- Data models and entities
- SwiftData models for persistence
- Pure data structures with no business logic

### 2. Views (`Views/`)
- SwiftUI views and UI components
- Display data and handle user interactions
- Communicate with ViewModels via `@StateObject` or `@ObservedObject`
- Should be as "dumb" as possible - no business logic

### 3. ViewModels (`ViewModels/`)
- Business logic and state management
- Inherit from `BaseViewModel`
- Observable objects that publish state changes
- Handle data fetching, transformations, and user actions

### 4. Services (`Services/`)
- Data repositories and external service integrations
- Core Data operations
- CloudKit sync services
- Network operations

### 5. Utilities (`Utilities/`)
- Helper classes, extensions, and utilities
- Color palettes, fonts, SF Symbols
- Error handling
- Common extensions

## Base Classes

### BaseViewModel
All ViewModels should inherit from `BaseViewModel` which provides:
- `isLoading` - Loading state management
- `errorMessage` - Error handling
- `onAppear()` / `onDisappear()` - Lifecycle methods
- `setLoading()` / `setError()` - Helper methods

**Example:**
```swift
@MainActor
class TodayViewModel: BaseViewModel {
    @Published var tasks: [Task] = []
    
    override func onAppear() {
        loadTasks()
    }
    
    func loadTasks() {
        setLoading(true)
        // Load tasks...
        setLoading(false)
    }
}
```

### BaseView
Provides common view modifiers and protocols:
- `ViewStateModifier` - Handles loading and error states
- `LoadingOverlay` - Standard loading indicator
- Error alerts

**Usage:**
```swift
struct MyView: View {
    @StateObject private var viewModel = MyViewModel()
    
    var body: some View {
        // Your view content
    }
    .viewState(viewModel: viewModel)
}
```

## Best Practices

1. **Views should be thin** - Only handle UI presentation
2. **ViewModels handle logic** - All business logic goes here
3. **Services handle data** - Data operations in Services, not ViewModels
4. **Use @Published** - For reactive state updates
5. **Error handling** - Use `ErrorHandler` utility for consistent error messages
6. **Loading states** - Always show loading indicators for async operations
7. **Lifecycle** - Use `onAppear()` / `onDisappear()` for setup/cleanup

## Example Implementation

See `ExampleMVVMView.swift` for a complete example of the MVVM pattern.

## Dependency Injection

Use `ViewModelFactory` for creating ViewModels with dependencies:
```swift
let viewModel = ViewModelFactory.shared.makeTodayViewModel()
```
