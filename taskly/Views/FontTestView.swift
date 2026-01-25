//
//  FontTestView.swift
//  taskly
//
//  Test view to verify all Sora font weights render correctly
//

import SwiftUI

struct FontTestView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                Text("Sora Font Family Test")
                    .font(.soraBold(size: 28))
                    .foregroundColor(.textPrimary)
                    .padding(.bottom, 8)
                
                // Font Weight Tests
                Group {
                    fontWeightSection(
                        title: "Thin (100)",
                        font: .soraThin(size: 18),
                        sampleText: "The quick brown fox jumps over the lazy dog"
                    )
                    
                    fontWeightSection(
                        title: "ExtraLight (200)",
                        font: .soraExtraLight(size: 18),
                        sampleText: "The quick brown fox jumps over the lazy dog"
                    )
                    
                    fontWeightSection(
                        title: "Light (300)",
                        font: .soraLight(size: 18),
                        sampleText: "The quick brown fox jumps over the lazy dog"
                    )
                    
                    fontWeightSection(
                        title: "Regular (400)",
                        font: .sora(size: 18),
                        sampleText: "The quick brown fox jumps over the lazy dog"
                    )
                    
                    fontWeightSection(
                        title: "SemiBold (600)",
                        font: .soraSemiBold(size: 18),
                        sampleText: "The quick brown fox jumps over the lazy dog"
                    )
                    
                    fontWeightSection(
                        title: "Bold (700)",
                        font: .soraBold(size: 18),
                        sampleText: "The quick brown fox jumps over the lazy dog"
                    )
                    
                    fontWeightSection(
                        title: "ExtraBold (800)",
                        font: .soraExtraBold(size: 18),
                        sampleText: "The quick brown fox jumps over the lazy dog"
                    )
                }
                
                Divider()
                    .padding(.vertical, 16)
                
                // Typography System Tests
                Group {
                    Text("Typography System")
                        .font(.soraBold(size: 24))
                        .foregroundColor(.textPrimary)
                        .padding(.bottom, 8)
                    
                    typographySection(
                        title: "Title/Date",
                        font: .soraTitle,
                        sampleText: "Monday, January 27, 2025"
                    )
                    
                    typographySection(
                        title: "Task Text",
                        font: .soraTask,
                        sampleText: "Complete project proposal"
                    )
                    
                    typographySection(
                        title: "Subtask Text",
                        font: .soraSubtask,
                        sampleText: "Review design mockups"
                    )
                    
                    typographySection(
                        title: "Button Text",
                        font: .soraButton,
                        sampleText: "Add Task"
                    )
                    
                    typographySection(
                        title: "Stats Text",
                        font: .soraStats,
                        sampleText: "5 of 12 tasks completed"
                    )
                }
                
                Divider()
                    .padding(.vertical, 16)
                
                // Size Tests
                Group {
                    Text("Size Variations")
                        .font(.soraBold(size: 24))
                        .foregroundColor(.textPrimary)
                        .padding(.bottom, 8)
                    
                    sizeTestSection(size: 12, label: "12pt")
                    sizeTestSection(size: 14, label: "14pt")
                    sizeTestSection(size: 15, label: "15pt")
                    sizeTestSection(size: 16, label: "16pt")
                    sizeTestSection(size: 18, label: "18pt")
                    sizeTestSection(size: 20, label: "20pt")
                    sizeTestSection(size: 24, label: "24pt")
                    sizeTestSection(size: 28, label: "28pt")
                }
                
                Divider()
                    .padding(.vertical, 16)
                
                // Color Tests
                Group {
                    Text("Color Variations")
                        .font(.soraBold(size: 24))
                        .foregroundColor(.textPrimary)
                        .padding(.bottom, 8)
                    
                    colorTestSection(
                        text: "Primary Text (87% opacity light / 90% dark)",
                        color: .textPrimary
                    )
                    
                    colorTestSection(
                        text: "Secondary Text (60% opacity light / 70% dark)",
                        color: .textSecondary
                    )
                    
                    colorTestSection(
                        text: "Tertiary Text (38% opacity light / 50% dark)",
                        color: .textTertiary
                    )
                }
            }
            .padding(24)
        }
        .background(Color.background)
    }
    
    // MARK: - Helper Views
    
    private func fontWeightSection(title: String, font: Font, sampleText: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.soraSemiBold(size: 14))
                .foregroundColor(.textSecondary)
            
            Text(sampleText)
                .font(font)
                .foregroundColor(.textPrimary)
            
            Text("0123456789 !@#$%^&*()")
                .font(font)
                .foregroundColor(.textSecondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.surface)
        .cornerRadius(12)
    }
    
    private func typographySection(title: String, font: Font, sampleText: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.soraSemiBold(size: 12))
                .foregroundColor(.textTertiary)
            
            Text(sampleText)
                .font(font)
                .foregroundColor(.textPrimary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.surface)
        .cornerRadius(12)
    }
    
    private func sizeTestSection(size: CGFloat, label: String) -> some View {
        HStack {
            Text(label)
                .font(.soraSemiBold(size: 12))
                .foregroundColor(.textTertiary)
                .frame(width: 60, alignment: .leading)
            
            Text("Sora Regular \(Int(size))pt")
                .font(.sora(size: size))
                .foregroundColor(.textPrimary)
        }
        .padding(.vertical, 4)
    }
    
    private func colorTestSection(text: String, color: Color) -> some View {
        Text(text)
            .font(.sora(size: 16))
            .foregroundColor(color)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.surface)
            .cornerRadius(12)
    }
}

#Preview {
    FontTestView()
        .frame(width: 800, height: 1000)
}
