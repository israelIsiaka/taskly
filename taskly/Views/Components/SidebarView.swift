//
//  SidebarView.swift
//  taskly
//
//  Created by Owen on 1/25/26.
//

import SwiftUI

struct SidebarView: View {
    @Binding var selectedTab: TabSelection
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.blue)
                        Text("Task Manager")
                            .font(.system(size: 16, weight: .bold))
                    }
                    Text("SEQUOIA EDITION")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(.secondary)
                        .padding(.leading, 24)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Navigation Items
                VStack(spacing: 4) {
                    SidebarRow(title: "Inbox", icon: "tray", count: 0, isSelected: selectedTab == .inbox) { selectedTab = .inbox }
                    SidebarRow(title: "Today", icon: "calendar", isSelected: selectedTab == .today) { selectedTab = .today }
                    SidebarRow(title: "Upcoming", icon: "clock", isSelected: selectedTab == .upcoming) { selectedTab = .upcoming }
                    SidebarRow(title: "Flagged", icon: "flag", isSelected: selectedTab == .flagged) { selectedTab = .flagged }
                    SidebarRow(title: "Completed", icon: "checkmark.circle", isSelected: selectedTab == .completed) { selectedTab = .completed }
                }
                .padding(.horizontal, 12)
                
                Spacer()
                
                // Profile Section
                ProfileFooter()
            }
            .frame(width: 260)
            .background(.ultraThinMaterial) // The "Glass" effect
        }
    }
}

// MARK: - Subviews

struct SidebarRow: View {
    let title: String
    let icon: String
    var count: Int? = nil
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .medium))
                
                Spacer()
                
                if let count = count {
                    Text("\(count)")
                        .font(.system(size: 12, weight: .bold))
                        .opacity(0.5)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .foregroundStyle(isSelected ? .blue : .primary.opacity(0.7))
            .contentShape(Rectangle()) // Makes the whole row hoverable
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(backgroundFill)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
    
    // Logic for the color transition
    private var backgroundFill: Color {
        if isSelected { return Color.blue.opacity(0.1) }
        return isHovering ? Color.primary.opacity(0.05) : Color.clear
    }
}

struct ProfileFooter: View {
    var body: some View {
        VStack(spacing: 0) {
            Divider().opacity(0.5)
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle.fill") // Replace with actual Image("avatar")
                    .resizable()
                    .frame(width: 36, height: 36)
                    .foregroundStyle(.gray)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Alex Rivera")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Pro Plan")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(16)
        }
    }
}

#Preview {
    SidebarView(selectedTab: .constant(.inbox))
        .preferredColorScheme(.light)
}
