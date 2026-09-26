//
//  View+RowBackground.swift
//  IceTime
//
//  Created by Marcel Mravec on 26.09.2026.
//

import SwiftUI

extension View {
    /// Frosted row background that lets the team color show through, in light and dark mode.
    func translucentRowBackground() -> some View {
        listRowBackground(Rectangle().fill(.thinMaterial))
    }
}
