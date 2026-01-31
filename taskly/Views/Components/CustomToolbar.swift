//
//  CustomToolbar.swift
//  taskly
//
//  Custom glassmorphic toolbar to replace system toolbar
//

import SwiftUI

struct CustomToolbar: View {
    @Binding var showNewTaskModal: Bool
    @Binding var searchQuery: String
    var isSearchFocused: FocusState<Bool>.Binding
    
    var body: some View {
        HStack(spacing: 12) {
            // Search Bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search tasks...", text: $searchQuery)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .focused(isSearchFocused)
                if !searchQuery.isEmpty {
                    Button {
                        searchQuery = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                Text("⌘K")
                    .font(.system(size: 10, weight: .medium))
                    .padding(4)
                    .background(.quaternary)
                    .cornerRadius(4)
            }
            .padding(.horizontal, 12)
            .frame(width: 240, height: 32)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.white.opacity(0.1), lineWidth: 0.5)
            )
            
            // Add Button with Bloom Shadow
            BloomButton(icon: "plus", action: {
                showNewTaskModal = true
            })
        }
        .padding(.trailing, 20)
    }
}
