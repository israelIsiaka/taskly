//
//  EmptyStateView.swift
//  taskly
//
//  Created by Owen on 1/25/26.
//

import SwiftUI

struct EmptyStateView: View {
    @Binding var showNewTaskModal: Bool
    
    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            
            // Central Glassmorphic Icon
            ZStack {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(width: 160, height: 160)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
                
                // Floating blue icon element
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(LinearGradient(colors: [.blue, .blue.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 64, height: 64)
                        .overlay(
                            Image(systemName: "photo.on.rectangle")
                                .foregroundColor(.white)
                                .font(.system(size: 24))
                        )
                        .shadow(color: .blue.opacity(0.3), radius: 15, x: 0, y: 10)
                    
                    // Small checkmark badge
                    Circle()
                        .fill(.white)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.blue)
                        )
                        .offset(x: 10, y: -10)
                }
            }
            
            // Text Content
            VStack(spacing: 12) {
                Text("All Clear!")
                    .font(.system(size: 32, weight: .bold))
                
                VStack(spacing: 4) {
                    Text("All tasks have been organized. Great work!")
                    Text("Take a moment to breathe.")
                }
                .font(.system(size: 18))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            }
            
            // Call to Action Button
            Button(action: {
                showNewTaskModal = true
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Task")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            }
            .buttonStyle(GlowButtonStyle())
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EmptyStateView(showNewTaskModal: .constant(false))
}
