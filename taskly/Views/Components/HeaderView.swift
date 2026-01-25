//
//  HeaderView.swift
//  taskly
//
//  Created by Owen on 1/25/26.
//

import SwiftUI

struct HeaderView: View {
    let title: String
    
    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "sun.max.fill")
                        .font(.caption)
                    Text("TODAY'S FOCUS")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(.secondary)
                
                HStack(spacing: 12) {
                    Text(title)
                        .font(.system(size: 34, weight: .bold))
                    
                    // Date Pickers/Arrows
                    HStack(spacing: 15) {
                        Image(systemName: "chevron.left")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
            
            Button { } label: {
                Label("Roll Over Incomplete", systemImage: "arrow.clockwise")
                    .font(.system(size: 13, weight: .medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.green.opacity(0.1))
                    .foregroundStyle(.green)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
    }
}
