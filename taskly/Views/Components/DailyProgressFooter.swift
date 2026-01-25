//
//  DailyProgressFooter.swift
//  taskly
//
//  Created by Owen on 1/25/26.
//

import SwiftUI

struct DailyProgressFooter: View {
    var progress: Double = 0.41 // Example: 5 of 12
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                HStack {
                    Text("DAILY PROGRESS")
                    Spacer()
                    Text("5 OF 12 COMPLETED")
                }
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.secondary)
                
                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.black.opacity(0.05))
                            .frame(height: 6)
                        
                        Capsule()
                            .fill(LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * progress, height: 6)
                    }
                }
                .frame(height: 6)
            }
            .padding(.horizontal, 40)
            
            // iCloud Status
            HStack(spacing: 6) {
                Text("SYNCING WITH ICLOUD")
                Circle()
                    .fill(.green)
                    .frame(width: 4, height: 4)
            }
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(.secondary)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(.white.opacity(0.5))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.black.opacity(0.05), lineWidth: 0.5))
        }
        .padding(.bottom, 20)
    }
}
