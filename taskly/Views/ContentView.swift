//
//  ContentView.swift
//  taskly
//
//  Main content view - entry point for the app UI
//

import SwiftUI
import SwiftData

enum TabSelection: String, CaseIterable {
    case inbox = "Inbox"
    case today = "Today"
    case upcoming = "Upcoming"
    case flagged = "Flagged"
    case completed = "Completed"
}

struct ContentView: View {
    @State private var selectedTab: TabSelection = .inbox
    @State private var showNewTaskModal = false
    @Query private var allTasks: [TaskItem]
    
    // Filter tasks based on selected tab
    private var filteredTasks: [TaskItem] {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
        
        switch selectedTab {
        case .inbox:
            // Tasks without a project
            return allTasks.filter { $0.project == nil && !$0.isCompleted }
        case .today:
            // Tasks due today
            return allTasks.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return dueDate >= startOfToday && dueDate < endOfToday && !task.isCompleted
            }
        case .upcoming:
            // Tasks due in the future
            return allTasks.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return dueDate > endOfToday && !task.isCompleted
            }
        case .flagged:
            // Flagged tasks
            return allTasks.filter { $0.isFlagged && !$0.isCompleted }
        case .completed:
            // Completed tasks
            return allTasks.filter { $0.isCompleted }
        }
    }
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedTab: $selectedTab)
        } detail: {
            VStack(spacing: 0) {
                // Custom App Bar - now at the very top
                HStack(alignment: .center) {
                    // Title on the left
                    Text(selectedTab.rawValue)
                        .font(.system(size: 20, weight: .bold))
                        .padding(.leading, 20)
                        .padding(.top, 8) // Small padding for visual balance
                    
                    Spacer()
                    
                    // Custom Toolbar on the right
                    CustomToolbar(showNewTaskModal: $showNewTaskModal)
                        .padding(.top, 8) // Match title padding
                }
                .frame(height: 60)
                .background(.ultraThinMaterial.opacity(0.5))
                
                // Content Area
                TaskDetailView(title: selectedTab.rawValue, tasks: filteredTasks, showNewTaskModal: $showNewTaskModal)
            }
            .ignoresSafeArea(edges: .top) // This is the key to shifting it up
            .background(MeshBackgroundView().ignoresSafeArea())
            .sheet(isPresented: $showNewTaskModal) {
                NewTaskModal(isPresented: $showNewTaskModal)
            }
            .onChange(of: showNewTaskModal) { oldValue, newValue in
                // Tasks will automatically refresh via @Query when new tasks are added
                // This ensures the view updates when the modal closes
            }
        }
        // .toolbar {
        //     // Hide the default toolbar
        //     ToolbarItem(placement: .automatic) {
        //         EmptyView()
        //     }
        // }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
