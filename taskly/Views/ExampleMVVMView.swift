//
//  ExampleMVVMView.swift
//  taskly
//
//  Example view demonstrating MVVM architecture usage
//  This file can be deleted once you understand the pattern
//

import SwiftUI
import Combine

/// Example view demonstrating MVVM pattern
struct ExampleMVVMView: View {
    @StateObject private var viewModel = ExampleViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("MVVM Example")
                .font(.soraTitle)
            
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else {
                Text("Data loaded successfully")
                    .font(.soraTask)
            }
            
            if let error = viewModel.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(ColorPalette.destructive)
                    .font(.soraStats)
            }
            
            Button("Load Data") {
                viewModel.loadData()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
        .viewState(viewModel: viewModel)
    }
}

/// Example ViewModel demonstrating BaseViewModel usage
@MainActor
class ExampleViewModel: BaseViewModel {
    @Published var data: String = ""
    
    override func setupBindings() {
        // Set up any Combine subscriptions here
    }
    
    override func onAppear() {
        super.onAppear()
        // Load initial data when view appears
        loadData()
    }
    
    func loadData() {
        setLoading(true)
        clearError()
        
        // Simulate async operation
        Task {
            do {
                // Simulate network call
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                
                // Simulate success
                data = "Example data loaded"
                setLoading(false)
            } catch {
                setError(ErrorHandler.userFriendlyMessage(from: error))
                setLoading(false)
            }
        }
    }
}

#Preview {
    ExampleMVVMView()
}
