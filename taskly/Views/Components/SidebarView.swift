//
//  SidebarView.swift
//  taskly
//
//  Native macOS sidebar using List component
//

import SwiftUI

enum NavigationItem: String, CaseIterable, Identifiable {
    case inbox = "Inbox"
    case today = "Today"
    case upcoming = "Upcoming"
    case someday = "Someday"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .inbox: return SFSymbols.inbox
        case .today: return SFSymbols.today
        case .upcoming: return SFSymbols.upcoming
        case .someday: return "folder"
        }
    }
}

struct SidebarView: View {
    @Binding var selectedView: NavigationItem
    @Binding var selectedProject: Project?
    let projects: [Project]
    
    @State private var selection: SidebarSelection?
    
    enum SidebarSelection: Hashable {
        case navigationItem(NavigationItem)
        case project(UUID) // Use UUID instead of Project for Hashable conformance
    }
    
    var body: some View {
        List(selection: $selection) {
            // Main Navigation Section
            Section {
                ForEach(NavigationItem.allCases) { item in
                    NavigationLink(value: SidebarSelection.navigationItem(item)) {
                        Label {
                            HStack {
                                Text(item.rawValue)
                                    .font(.sora(size: 15))
                                
                                Spacer()
                                
                                if getTaskCount(for: item) > 0 {
                                    Text("\(getTaskCount(for: item))")
                                        .font(.sora(size: 13))
                                        .foregroundColor(ColorPalette.textTertiary)
                                }
                            }
                        } icon: {
                            Image(systemName: item.icon)
                                .font(.system(size: 16))
                                .foregroundColor(selectedView == item ? ColorPalette.primaryAction : ColorPalette.textSecondary)
                                .frame(width: 20)
                        }
                    }
                    .tag(SidebarSelection.navigationItem(item))
                }
            }
            
            // Projects Section - only show if there are projects
            if !projects.isEmpty {
                Section {
                    ForEach(projects.prefix(10), id: \.id) { project in
                        NavigationLink(value: SidebarSelection.project(project.id)) {
                            Label {
                                HStack {
                                    Text(project.name)
                                        .font(.sora(size: 14))
                                    
                                    Spacer()
                                    
                                    if project.taskCount > 0 {
                                        Text("\(project.taskCount)")
                                            .font(.sora(size: 13))
                                            .foregroundColor(ColorPalette.textTertiary)
                                    }
                                }
                            } icon: {
                                Circle()
                                    .fill(project.colorValue)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .tag(SidebarSelection.project(project.id))
                    }
                } header: {
                    Text("PROJECTS")
                        .font(.soraSemiBold(size: 11))
                        .foregroundColor(ColorPalette.textTertiary)
                        .tracking(0.5)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Task Manager")
        .navigationSplitViewColumnWidth(min: 200, ideal: 240)
        .onAppear {
            // Set initial selection
            selection = .navigationItem(selectedView)
        }
        .onChange(of: selection) { oldValue, newValue in
            if let newValue = newValue {
                switch newValue {
                case .navigationItem(let item):
                    selectedView = item
                    selectedProject = nil
                case .project(let projectId):
                    selectedProject = projects.first { $0.id == projectId }
                }
            }
        }
        .onChange(of: selectedView) { oldValue, newValue in
            if selectedProject == nil {
                selection = .navigationItem(newValue)
            }
        }
    }
    
    private func getTaskCount(for item: NavigationItem) -> Int {
        // TODO: Implement actual task counts
        return 0
    }
}

