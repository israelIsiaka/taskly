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
    case flagged = "Flagged"
    case completed = "Completed"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .inbox: return SFSymbols.inbox
        case .today: return SFSymbols.today
        case .upcoming: return SFSymbols.upcoming
        case .flagged: return SFSymbols.flagged
        case .completed: return SFSymbols.completed 
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
        VStack(spacing: 0) {
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
            .navigationSplitViewColumnWidth(min: 200, ideal: 240, max: 300)
            
            // User Profile Card at bottom
            UserProfileCard()
        }
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

struct BottomRoundedRectangle: Shape {
    var cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = cornerRadius
        
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - radius, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - radius),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        path.closeSubpath()
        
        return path
    }
}

struct UserProfileCard: View {
    @StateObject private var cloudKitService = CloudKitService.shared
    @State private var isLoading = true
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            // Profile Picture
            Group {
                if let imageData = cloudKitService.userProfileImage,
                   let nsImage = NSImage(data: imageData) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.2, green: 0.4, blue: 0.5),
                                    Color(red: 0.15, green: 0.3, blue: 0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Text(cloudKitService.userInitials)
                                .font(.soraSemiBold(size: 16))
                                .foregroundColor(.white)
                        )
                }
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            
            // User Info
            VStack(alignment: .leading, spacing: 2) {
                Text(cloudKitService.userName ?? "User")
                    .font(.soraMedium(size: 14))
                    .foregroundColor(ColorPalette.textPrimary)
                
                Text("Pro Plan")
                    .font(.sora(size: 12))
                    .foregroundColor(ColorPalette.textTertiary)
            }
            
            Spacer()
            
            // Settings Icon
            Button(action: {
                // Handle settings action
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16))
                    .foregroundColor(ColorPalette.textSecondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(.regularMaterial)
        .clipShape(BottomRoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
        .task {
            if isLoading {
                await cloudKitService.fetchUserInfo()
                isLoading = false
            }
        }
    }
}

