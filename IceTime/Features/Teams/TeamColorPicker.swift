//
//  TeamColorPicker.swift
//  IceTime
//
//  Created by Marcel Mravec on 25.09.2026.
//

import SwiftUI

/// A row of color circles; tapping one picks it and closes the sheet.
struct TeamColorPicker: View {
    let selected: TeamColor
    let onSelect: (TeamColor) -> Void
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Team Color")
                .font(.headline)
            HStack(spacing: 14) {
                ForEach(TeamColor.allCases) { color in
                    Button {
                        select(color)
                    } label: {
                        Circle()
                            .fill(color.gradient)
                            .frame(width: 44, height: 44)
                            .overlay {
                                if color == selected {
                                    Image(systemName: "checkmark")
                                        .font(.headline.bold())
                                        .foregroundStyle(.white)
                                }
                            }
                    }
                    .accessibilityLabel(color.rawValue.capitalized)
                }
            }
        }
        .padding()
    }
    
    private func select(_ color: TeamColor) {
        onSelect(color)
        dismiss()
    }
}
