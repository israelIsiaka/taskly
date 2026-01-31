//
//  TaskDetailView.swift
//  taskly
//
//  Created by Owen on 1/25/26.
//

import SwiftUI

struct TaskDetailView: View {
    let title: String
    let tasks: [TaskItem] // Your data model
    @Binding var showNewTaskModal: Bool
    @State private var selectedTask: TaskItem? = nil
    
    var body: some View {
        ZStack {
            if tasks.isEmpty {
                // Empty State
                EmptyStateView(showNewTaskModal: $showNewTaskModal)
            } else {
                VStack(spacing: 0) {
                    // Main Content Area - full width, does not resize when detail opens
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 24) {
                                HeaderView(title: title)
                                
                                AddTaskBar()
                                
                                // Task List
                                VStack(spacing: 12) {
                                    ForEach(tasks) { task in
                                        TaskCard(task: task)
                                            .onTapGesture {
                                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                    selectedTask = task
                                                }
                                            }
                                    }
                                }
                                
                                Spacer(minLength: 100)
                            }
                            .padding(.horizontal, 40)
                            .padding(.top, 40)
                        }
                        
                        // Fixed Bottom Progress - shifts with content
                        DailyProgressFooter()
                    }
                    .frame(maxWidth: .infinity)
                }
                .overlay(alignment: .trailing) {
                    if let task = selectedTask {
                        TaskItemDetailView(task: task, isPresented: Binding(
                            get: { selectedTask != nil },
                            set: { if !$0 { selectedTask = nil } }
                        ))
                        .transition(.move(edge: .trailing))
                        .frame(width: 400)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .id(task.id) // Force refresh when task changes
                    }
                }
            }
        }
    }
}
#Preview {
    TaskDetailView(
        title: "Today",
        tasks: [],
        showNewTaskModal: .constant(false)
    )
}
