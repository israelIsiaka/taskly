//
//  BaseViewModel.swift
//  taskly
//
//  Base ViewModel class for MVVM architecture
//

import Foundation
import SwiftUI
import Combine

/// Base protocol for all ViewModels
/// Provides common functionality like loading states, error handling, and lifecycle methods
@MainActor
protocol ViewModelProtocol: ObservableObject {
    /// Indicates if the view model is currently loading data
    var isLoading: Bool { get set }
    
    /// Current error state
    var errorMessage: String? { get set }
    
    /// Called when the view appears
    func onAppear()
    
    /// Called when the view disappears
    func onDisappear()
}

/// Base ViewModel class implementing common functionality
@MainActor
class BaseViewModel: ObservableObject, ViewModelProtocol {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    /// Cancellables storage for Combine subscriptions
    var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    /// Override this method to set up any bindings or subscriptions
    func setupBindings() {
        // Override in subclasses
    }
    
    /// Called when the view appears
    func onAppear() {
        // Override in subclasses
    }
    
    /// Called when the view disappears
    func onDisappear() {
        // Override in subclasses
    }
    
    /// Set loading state
    func setLoading(_ loading: Bool) {
        isLoading = loading
    }
    
    /// Set error message
    func setError(_ message: String?) {
        errorMessage = message
        // Auto-clear error after 5 seconds
        if message != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                guard let self = self else { return }
                if self.errorMessage == message {
                    self.errorMessage = nil
                }
            }
        }
    }
    
    /// Clear error
    func clearError() {
        errorMessage = nil
    }
    
    deinit {
        cancellables.removeAll()
    }
}

