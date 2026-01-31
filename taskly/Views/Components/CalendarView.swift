//
//  CalendarView.swift
//  taskly
//
//  Calendar view - view tasks by date.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Binding var showNewTaskModal: Bool
    @Query private var allTasks: [TaskItem]
    @State private var displayedMonth: Date = Date()
    @State private var selectedDate: Date? = Date()
    @State private var selectedTask: TaskItem? = nil

    private let calendar = Calendar.current
    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    private func tasks(for date: Date) -> [TaskItem] {
        allTasks.filter { task in
            guard let due = task.dueDate else { return false }
            return calendar.isDate(due, inSameDayAs: date)
        }
    }

    private func taskCount(for date: Date) -> Int {
        tasks(for: date).count
    }

    private var firstDayOfMonth: Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
    }

    private var numberOfDaysInMonth: Int {
        calendar.range(of: .day, in: .month, for: displayedMonth)!.count
    }

    private var firstWeekdayOfMonth: Int {
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        return weekday - 1 // 0 = Sunday
    }

    private var leadingEmptyCells: Int {
        firstWeekdayOfMonth
    }

    private var totalCells: Int {
        leadingEmptyCells + numberOfDaysInMonth
    }

    private var rows: Int {
        (totalCells + 6) / 7
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                // Header with month navigation
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CALENDAR")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.secondary)
                        HStack(spacing: 16) {
                            Text(monthTitle)
                                .font(.system(size: 28, weight: .bold))
                            HStack(spacing: 8) {
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                                    }
                                } label: {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 14, weight: .semibold))
                                        .frame(width: 32, height: 32)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                                    }
                                } label: {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .frame(width: 32, height: 32)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                }

                // Weekday headers
                HStack(spacing: 0) {
                    ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                        Text(symbol)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, 8)

                // Month grid
                VStack(spacing: 6) {
                    ForEach(0..<rows, id: \.self) { row in
                        HStack(spacing: 6) {
                            ForEach(0..<7, id: \.self) { col in
                                let index = row * 7 + col
                                dayCell(for: index)
                            }
                        }
                    }
                }

                // Selected date tasks
                if let date = selectedDate {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(dateLabel(for: date))
                                .font(.system(size: 18, weight: .semibold))
                            Spacer()
                            if !tasks(for: date).isEmpty {
                                Text("\(tasks(for: date).count) task\(tasks(for: date).count == 1 ? "" : "s")")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondary)
                            }
                        }

                        let dayTasks = tasks(for: date)
                        if dayTasks.isEmpty {
                            Text("No tasks due this day")
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 24)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(dayTasks) { task in
                                    TaskCard(task: task)
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                selectedTask = task
                                            }
                                        }
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                } else {
                    Text("Select a date to view tasks")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 24)
                }

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 40)
            .padding(.top, 40)
        }
        .background(MeshBackgroundView().ignoresSafeArea())
        .overlay(alignment: .trailing) {
            if let task = selectedTask {
                TaskItemDetailView(task: task, isPresented: Binding(
                    get: { selectedTask != nil },
                    set: { if !$0 { selectedTask = nil } }
                ))
                .transition(.move(edge: .trailing))
                .frame(width: 400)
                .frame(maxHeight: .infinity, alignment: .top)
                .id(task.id)
            }
        }
    }

    @ViewBuilder
    private func dayCell(for index: Int) -> some View {
        let dayNumber: Int? = {
            if index < leadingEmptyCells { return nil }
            let d = index - leadingEmptyCells + 1
            return d <= numberOfDaysInMonth ? d : nil
        }()

        let cellDate: Date? = {
            guard let day = dayNumber else { return nil }
            return calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)
        }()

        let isToday = cellDate.map { calendar.isDateInToday($0) } ?? false
        let isSelected: Bool = {
            guard let cell = cellDate, let sel = selectedDate else { return false }
            return calendar.isDate(cell, inSameDayAs: sel)
        }()
        let count = cellDate.map { taskCount(for: $0) } ?? 0

        Button {
            guard let date = cellDate else { return }
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDate = date
            }
        } label: {
            VStack(spacing: 4) {
                if let day = dayNumber {
                    Text("\(day)")
                        .font(.system(size: 14, weight: isToday || isSelected ? .semibold : .regular))
                        .foregroundStyle(foregroundFor(isToday: isToday, isSelected: isSelected))
                    if count > 0 {
                        Circle()
                            .fill(isSelected ? Color.white : Color.blue)
                            .frame(width: min(6, 4 + CGFloat(min(count, 3))), height: 6)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(backgroundColor(isToday: isToday, isSelected: isSelected))
            )
        }
        .buttonStyle(.plain)
        .disabled(dayNumber == nil)
    }

    private func foregroundFor(isToday: Bool, isSelected: Bool) -> Color {
        if isSelected { return .white }
        if isToday { return .blue }
        return .primary
    }

    private func backgroundColor(isToday: Bool, isSelected: Bool) -> Color {
        if isSelected { return .blue }
        if isToday { return .blue.opacity(0.15) }
        return .clear
    }

    private func dateLabel(for date: Date) -> String {
        if calendar.isDateInToday(date) {
            return "Today"
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    CalendarView(showNewTaskModal: .constant(false))
        .modelContainer(for: [TaskItem.self, Project.self], inMemory: true)
}
