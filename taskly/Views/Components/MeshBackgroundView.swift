//
//  MeshBackgroundView.swift
//  taskly
//
//  Created by Owen on 1/25/26.
//

import SwiftUI

struct MeshBackgroundView: View {
    @Environment(\.colorScheme) var scheme
    
    // Define Dark vs Light palettes
    var colors: [Color] {
        scheme == .dark ? [
            .black, .indigo.opacity(0.3), .blue.opacity(0.2),
            .black, .purple.opacity(0.2), .black,
            .blue.opacity(0.1), .black, .indigo.opacity(0.3)
        ] : [
            .white, .purple.opacity(0.1), .pink.opacity(0.1),
            .white, .blue.opacity(0.1), .white,
            .purple.opacity(0.1), .white, .indigo.opacity(0.1)
        ]
    }

    var body: some View {
        MeshGradient(width: 3, height: 3, points: [
            [0, 0], [0.5, 0], [1, 0],
            [0, 0.5], [0.5, 0.5], [1, 0.5],
            [0, 1], [0.5, 1], [1, 1]
        ], colors: colors)
        .background(scheme == .dark ? Color(white: 0.05) : .white)
        .ignoresSafeArea()
    }
}
