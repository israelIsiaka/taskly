//
//  MainWindowView.swift
//  taskly
//
//  Main window structure using native macOS NavigationSplitView
//

import SwiftUI
import SwiftData

struct MainWindowView: View {
    @State private var selectedView: NavigationItem = .inbox
    @State private var selectedProject: Project?
    @State private var searchText: String = ""
    @Query private var projects: [Project]
    
    private var currentTitle: String {
        if let project = selectedProject {
            return project.name
        }
        return selectedView.rawValue
    }
    
    @State private var sidebarVisibility: NavigationSplitViewVisibility = .doubleColumn
    
    var body: some View {
        NavigationSplitView(columnVisibility: $sidebarVisibility) {
            // Native macOS Sidebar
            SidebarView(
                selectedView: $selectedView,
                selectedProject: $selectedProject,
                projects: projects
            )
        } detail: {
            // Main Content Area
            VStack(spacing: 0) {
                // Header with page title
                VStack(spacing: 0) {
                    // Page Title Row
                    HStack {
                        Text(currentTitle)
                            .font(.soraBold(size: 28))
                            .foregroundColor(ColorPalette.textPrimary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.top, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.sm)
                    
                    // Header Bar
                    HeaderView(searchText: $searchText) {
                        // Handle add task
                    }
                }
                
                Divider()
                
                // Content View
                Group {
                    if let project = selectedProject {
                        // Project view (to be implemented)
                        Text("Project: \(project.name)")
                            .font(.soraTitle)
                            .foregroundColor(ColorPalette.textPrimary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        switch selectedView {
                        case .inbox:
                            InboxView()
                        case .today:
                            Text("Today View")
                                .font(.soraTitle)
                                .foregroundColor(ColorPalette.textPrimary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        case .upcoming:
                            Text("Upcoming View")
                                .font(.soraTitle)
                                .foregroundColor(ColorPalette.textPrimary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        case .flagged:
                            Text("Flagged View")
                                .font(.soraTitle)
                                .foregroundColor(ColorPalette.textPrimary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        case .completed:
                            Text("Completed View")
                                .font(.soraTitle)
                                .foregroundColor(ColorPalette.textPrimary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .background(ColorPalette.background)
        .frame(minWidth: 800, minHeight: 600)
        .toolbar {
            // Hide sidebar toggle button
            ToolbarItem(placement: .automatic) {
                EmptyView()
            }
        }
        .onAppear {
            // Force sidebar to always be visible
            sidebarVisibility = .doubleColumn
        }
        .onChange(of: sidebarVisibility) { oldValue, newValue in
            // Prevent sidebar from being collapsed - always keep it visible
            if newValue != .doubleColumn {
                sidebarVisibility = .doubleColumn
            }
        }
        .onChange(of: selectedProject) { oldValue, newValue in
            if newValue != nil {
                selectedView = .inbox // Reset to inbox when project is selected
            }
        }
    }
}
