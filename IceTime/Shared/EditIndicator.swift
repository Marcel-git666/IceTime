//
//  EditIndicator.swift
//  IceTime
//
//  Created by Marcel Mravec on 25.09.2026.
//

import SwiftUI

/// Pencil shown on editable rows while a list is in edit mode.
struct EditIndicator: View {
    var body: some View {
        Image(systemName: "pencil.circle.fill")
            .font(.title2)
            .foregroundStyle(.tint)
            .accessibilityLabel("Edit")
    }
}
