//
//  InboxView.swift
//  taskly
//
//  Inbox view - shows unorganized tasks
//

import SwiftUI
import SwiftData

struct InboxView: View {
    @Query private var allTasks: [TaskItem]
    
    // Filter tasks without project in Swift (predicates have limitations with optionals)
    private var inboxTasks: [TaskItem] {
        allTasks.filter { $0.project == nil }
    }
    
    @State private var showAddTask = false
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    ColorPalette.background,
                    ColorPalette.primaryAction.opacity(0.03),
                    Color.purple.opacity(0.02)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Content
                if inboxTasks.isEmpty {
                    EmptyStateView(
                        icon: "tray",
                        title: "Inbox Zero!",
                        message: "All tasks have been organized. Great work! Take a moment to breathe.",
                        buttonTitle: "+ Add Task to Inbox",
                        buttonAction: {
                            showAddTask = true
                        }
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: DesignSystem.Spacing.sm) {
                            ForEach(inboxTasks) { task in
                                TaskCardView(task: task)
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.vertical, DesignSystem.Spacing.md)
                    }
                }
                
                Spacer()
                
                // Footer - Sync Status
                HStack {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Circle()
                            .fill(ColorPalette.success)
                            .frame(width: 6, height: 6)
                        Text("• SYNCING WITH ICLOUD")
                            .font(.sora(size: 11))
                            .foregroundColor(ColorPalette.success)
                    }
                    
                    Spacer()
                    
                    // Dark mode toggle (placeholder)
                    Button(action: {}) {
                        Image(systemName: "moon")
                            .font(.system(size: 14))
                            .foregroundColor(ColorPalette.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.vertical, DesignSystem.Spacing.sm)
            }
        }
        .sheet(isPresented: $showAddTask) {
            // Add Task Modal (to be implemented)
            Text("Add Task Modal")
        }
    }
}
