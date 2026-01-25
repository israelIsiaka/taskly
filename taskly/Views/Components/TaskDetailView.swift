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
    
    var body: some View {
        ZStack {
            if tasks.isEmpty {
                // Empty State
                EmptyStateView(showNewTaskModal: $showNewTaskModal)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        HeaderView(title: title)
                        
                        AddTaskBar()
                        
                        // Task List
                        VStack(spacing: 12) {
                            ForEach(tasks) { task in
                                TaskCard(task: task)
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 40)
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
