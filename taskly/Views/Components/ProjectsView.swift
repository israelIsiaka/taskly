//
//  ProjectsView.swift
//  taskly
//
//  Projects list view with create project and project-scoped task list.
//

import SwiftUI
import SwiftData

struct ProjectsView: View {
    @Binding var showNewTaskModal: Bool
    @Binding var showNewProjectModal: Bool
    @Query(sort: \Project.name) private var projects: [Project]
    @Query private var allTasks: [TaskItem]
    @Environment(\.modelContext) private var modelContext

    private func tasksFor(project: Project) -> [TaskItem] {
        allTasks.filter { $0.project?.id == project.id }
    }

    private func taskCount(for project: Project) -> Int {
        tasksFor(project: project).count
    }

    var body: some View {
        ZStack {
            if projects.isEmpty {
                projectsEmptyState
            } else {
                NavigationStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            HStack(alignment: .bottom) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("PROJECTS")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.secondary)
                                    Text("Projects")
                                        .font(.system(size: 34, weight: .bold))
                                }
                                Spacer()
                                Button(action: { showNewProjectModal = true }) {
                                    Label("New Project", systemImage: "plus.circle.fill")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(
                                            LinearGradient(
                                                colors: [Color.purple, Color(red: 0.5, green: 0, blue: 1)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .buttonStyle(.plain)
                            }

                            VStack(spacing: 8) {
                                ForEach(projects, id: \.id) { project in
                                    NavigationLink(destination: projectTaskDetailView(project: project)) {
                                        ProjectRowView(project: project, taskCount: taskCount(for: project))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 40)
                    }
                    .background(MeshBackgroundView().ignoresSafeArea())
                }
            }
        }
    }

    private var projectsEmptyState: some View {
        VStack(spacing: 28) {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(width: 160, height: 160)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 56))
                    .foregroundStyle(.secondary)
            }
            VStack(spacing: 12) {
                Text("No projects yet")
                    .font(.system(size: 32, weight: .bold))
                VStack(spacing: 4) {
                    Text("Create a project to organize your tasks.")
                    Text("You can assign tasks to projects when adding them.")
                }
                .font(.system(size: 18))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            }
            Button(action: { showNewProjectModal = true }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Create Project")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            }
            .buttonStyle(GlowButtonStyle())
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func projectTaskDetailView(project: Project) -> some View {
        ZStack {
            ProjectMeshBackgroundView(accentColor: project.colorValue)
            TaskDetailView(
                title: project.name,
                tasks: tasksFor(project: project),
                showNewTaskModal: $showNewTaskModal
            )
        }
    }
}

// MARK: - Project Row

struct ProjectRowView: View {
    let project: Project
    let taskCount: Int
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: project.icon)
                .font(.system(size: 18))
                .frame(width: 24)
                .foregroundStyle(project.colorValue)
            Circle()
                .fill(project.colorValue)
                .frame(width: 8, height: 8)
            Text(project.name)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.primary)
            Spacer()
            Text("\(taskCount)")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.secondary)
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isHovering ? Color.primary.opacity(0.05) : Color.clear)
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - New Project Modal

struct NewProjectModal: View {
    @Binding var isPresented: Bool
    @State private var projectName = ""
    @State private var projectDescription = ""
    @State private var selectedColor = "#007AFF"
    @State private var showValidationError = false
    @State private var isCreating = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme

    private let colorPresets = ["#007AFF", "#34C759", "#FF9500", "#FF3B30", "#AF52DE", "#5856D6"]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text("New Project")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(ColorPalette.textPrimary)
                Spacer()
                Button(action: {
                    resetForm()
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(ColorPalette.textTertiary)
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("PROJECT NAME")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(ColorPalette.textTertiary)
                TextField("Enter project name", text: $projectName)
                    .font(.system(size: 22, weight: .semibold))
                    .textFieldStyle(.plain)
                    .foregroundColor(ColorPalette.textPrimary)
                if showValidationError && projectName.trimmingCharacters(in: .whitespaces).isEmpty {
                    Text("Project name is required")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("DESCRIPTION (OPTIONAL)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(ColorPalette.textTertiary)
                TextField("Add a description...", text: $projectDescription, axis: .vertical)
                    .font(.system(size: 14))
                    .textFieldStyle(.plain)
                    .foregroundColor(ColorPalette.textSecondary)
                    .lineLimit(3...6)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("COLOR (OPTIONAL)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(ColorPalette.textTertiary)
                HStack(spacing: 12) {
                    ForEach(colorPresets, id: \.self) { hex in
                        Circle()
                            .fill(Color(hex: hex) ?? .blue)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle()
                                    .stroke(selectedColor == hex ? Color.white : Color.clear, lineWidth: 2)
                            )
                            .onTapGesture { selectedColor = hex }
                    }
                }
            }

            HStack(spacing: 16) {
                Spacer()
                Button("Cancel") {
                    resetForm()
                    isPresented = false
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(ColorPalette.textSecondary)
                .disabled(isCreating)

                Button("Create Project") {
                    createProject()
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [Color.purple, Color(red: 0.5, green: 0, blue: 1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .disabled(isCreating || projectName.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(isCreating || projectName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
            }
        }
        .padding(32)
        .frame(width: 480)
        .background(ColorPalette.background)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.5 : 0.15), radius: 50, x: 0, y: 25)
    }

    private func resetForm() {
        projectName = ""
        projectDescription = ""
        selectedColor = "#007AFF"
        showValidationError = false
    }

    private func createProject() {
        let trimmed = projectName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            showValidationError = true
            return
        }
        isCreating = true
        defer { isCreating = false }
        let project = Project(
            name: trimmed,
            color: selectedColor,
            icon: "folder",
            projectDescription: projectDescription.trimmingCharacters(in: .whitespaces)
        )
        modelContext.insert(project)
        do {
            try modelContext.save()
            resetForm()
            isPresented = false
        } catch {
            // Error already surfaced; isCreating reset via defer
        }
    }
}

#Preview("Projects list") {
    ProjectsView(showNewTaskModal: .constant(false), showNewProjectModal: .constant(false))
        .modelContainer(for: [Project.self, TaskItem.self], inMemory: true)
}

#Preview("Projects empty") {
    ProjectsView(showNewTaskModal: .constant(false), showNewProjectModal: .constant(false))
        .modelContainer(for: [Project.self, TaskItem.self], inMemory: true)
}
