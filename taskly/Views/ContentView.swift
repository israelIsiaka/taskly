//
//  ContentView.swift
//  taskly
//
//  Main content view - entry point for the app UI
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        MainWindowView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
