//
//  BaseView.swift
//  taskly
//
//  Base view protocols and modifiers for consistent UI
//

import SwiftUI

/// Protocol for views that use a ViewModel
protocol ViewModelView: View {
    associatedtype ViewModelType: ViewModelProtocol
    var viewModel: ViewModelType { get }
}

/// Base view modifier for handling loading and error states
struct ViewStateModifier: ViewModifier {
    @ObservedObject var viewModel: BaseViewModel
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if viewModel.isLoading {
                    LoadingOverlay()
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
    }
}

/// Loading overlay view
struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
            
            ProgressView()
                .scaleEffect(1.5)
                .padding(24)
                .background(ColorPalette.surface)
                .cornerRadius(12)
        }
    }
}

/// Extension to easily apply view state modifier
extension View {
    func viewState(viewModel: BaseViewModel) -> some View {
        modifier(ViewStateModifier(viewModel: viewModel))
    }
}
