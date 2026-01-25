//
//  tasklyApp.swift
//  taskly
//
//  Created by Owen on 1/25/26.
//

import SwiftUI
import SwiftData

@main
struct tasklyApp: App {
    init() {
        // Register Sora fonts on app launch
        FontHelper.registerFonts()
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TaskItem.self,
            Project.self,
            Subtask.self,
            Tag.self,
        ])
        
        // Configure for local-only storage (no CloudKit)
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
            // No cloudKitDatabase parameter = local SQLite storage only
        )

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("✅ ModelContainer created successfully with local-only storage")
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Set up SwiftData manager with context
                    if let context = sharedModelContainer.mainContext as? ModelContext {
                        SwiftDataManager.shared.setContext(context)
                    }
                    
                    // Register services in dependency container
                    DependencyContainer.shared.registerSingleton(TaskServiceProtocol.self) {
                        TaskService()
                    }
                    DependencyContainer.shared.registerSingleton(ProjectServiceProtocol.self) {
                        ProjectService()
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .modelContainer(sharedModelContainer)
    }
}

