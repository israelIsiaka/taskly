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

// MARK: - Project-colored mesh background

/// Mesh background tinted with a project (or any) accent color for project detail screens.
struct ProjectMeshBackgroundView: View {
    @Environment(\.colorScheme) var scheme
    let accentColor: Color

    private var colors: [Color] {
        let base = scheme == .dark ? Color.black : Color.white
        let tint = accentColor
        let opacityStrong: Double = scheme == .dark ? 0.35 : 0.18
        let opacityMid: Double = scheme == .dark ? 0.22 : 0.12
        let opacitySoft: Double = scheme == .dark ? 0.12 : 0.06
        return [
            base, tint.opacity(opacityMid), tint.opacity(opacitySoft),
            tint.opacity(opacitySoft), tint.opacity(opacityStrong), tint.opacity(opacitySoft),
            tint.opacity(opacitySoft), tint.opacity(opacityMid), base
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
