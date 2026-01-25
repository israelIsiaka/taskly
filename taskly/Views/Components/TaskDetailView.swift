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
                HStack(spacing: 0) {
                    // Main Content Area
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
                    .frame(maxWidth: .infinity)
                    
                    // Right Side: Slide-in Detail Panel
                    if let task = selectedTask {
                        TaskItemDetailView(task: task, isPresented: Binding(
                            get: { selectedTask != nil },
                            set: { if !$0 { selectedTask = nil } }
                        ))
                        .transition(.move(edge: .trailing))
                        .frame(width: 400)
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                }
            }
            
            // Fixed Bottom Progress - only show when there are tasks
            if !tasks.isEmpty {
                VStack {
                    Spacer()
                    DailyProgressFooter()
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
