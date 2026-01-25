//
//  AddTaskBar.swift
//  taskly
//
//  Created by Owen on 1/25/26.
//

import SwiftUI

struct AddTaskBar: View {
    @State private var text = ""
    
    var body: some View {
        HStack {
            Image(systemName: "plus.circle")
                .foregroundStyle(.secondary)
            TextField("Add a new task...", text: $text)
                .textFieldStyle(.plain)
        }
        .padding(16)
        .background(Color.white.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }
}
