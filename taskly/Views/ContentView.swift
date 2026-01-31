//
//  ContentView.swift
//  taskly
//
//  Main content view - entry point for the app UI
//

import SwiftUI
import SwiftData

enum TabSelection: String, CaseIterable {
    case pending = "Pending"
    case today = "Today"
    case calendar = "Calendar"
    case projects = "Projects"
    case completed = "Completed"
}

struct ContentView: View {
    @State private var selectedTab: TabSelection = .pending
    @State private var showNewTaskModal = false
    @State private var showNewProjectModal = false
    @State private var searchQuery = ""
    @FocusState private var isSearchFocused: Bool
    @Query private var allTasks: [TaskItem]
    
    // Filter tasks based on selected tab, then by search query if non-empty
    private var filteredTasks: [TaskItem] {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
        let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let tabFiltered: [TaskItem]
        switch selectedTab {
        case .pending:
            tabFiltered = allTasks.filter { !$0.isCompleted }
        case .today:
            tabFiltered = allTasks.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return dueDate >= startOfToday && dueDate < endOfToday
            }
        case .calendar, .projects:
            tabFiltered = []
        case .completed:
            tabFiltered = allTasks.filter { task in
                if task.isCompleted { return true }
                if let dueDate = task.dueDate { return dueDate < now }
                return false
            }
        }

        if q.isEmpty { return tabFiltered }
        return tabFiltered.filter { task in
            task.title.lowercased().contains(q) ||
            task.taskDescription.lowercased().contains(q) ||
            (task.project?.name.lowercased().contains(q) ?? false)
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
                    CustomToolbar(
                        showNewTaskModal: $showNewTaskModal,
                        searchQuery: $searchQuery,
                        isSearchFocused: $isSearchFocused
                    )
                    .padding(.top, 8) // Match title padding
                }
                .frame(height: 60)
                .background(.ultraThinMaterial.opacity(0.5))
                
                // Content Area
                if selectedTab == .projects {
                    ProjectsView(showNewTaskModal: $showNewTaskModal, showNewProjectModal: $showNewProjectModal)
                } else if selectedTab == .calendar {
                    CalendarView(showNewTaskModal: $showNewTaskModal)
                } else {
                    TaskDetailView(title: selectedTab.rawValue, tasks: filteredTasks, showNewTaskModal: $showNewTaskModal)
                }
            }
            .ignoresSafeArea(edges: .top) // This is the key to shifting it up
            .background(MeshBackgroundView().ignoresSafeArea())
            .sheet(isPresented: $showNewTaskModal) {
                NewTaskModal(isPresented: $showNewTaskModal)
            }
            .sheet(isPresented: $showNewProjectModal) {
                NewProjectModal(isPresented: $showNewProjectModal)
            }
            .onChange(of: showNewTaskModal) { oldValue, newValue in
                // Tasks will automatically refresh via @Query when new tasks are added
            }
            .background {
                // Keyboard shortcuts (hidden)
                Group {
                    Button("Search") { isSearchFocused = true }
                        .keyboardShortcut("k", modifiers: .command)
                    Button("New Task") { showNewTaskModal = true }
                        .keyboardShortcut("n", modifiers: .command)
                    Button("New Project") { showNewProjectModal = true }
                        .keyboardShortcut("n", modifiers: [.command, .shift])
                }
                .frame(width: 0, height: 0)
                .opacity(0)
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
        .modelContainer(for: [TaskItem.self, Project.self, Subtask.self, Tag.self], inMemory: true)
}
