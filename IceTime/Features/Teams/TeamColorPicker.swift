//
//  TeamColorPicker.swift
//  IceTime
//
//  Created by Marcel Mravec on 25.09.2026.
//

import SwiftUI

/// A row of color circles; tapping one picks it and closes the sheet.
struct TeamColorPicker: View {
    /// Height of the sheet this picker is shown in.
    static let sheetHeight = 160.0
    
    private enum Layout {
        static let spacing = 20.0
        static let circleSpacing = 14.0
        /// Apple's minimum tap target size.
        static let circleSize = 44.0
    }
    
    let selected: TeamColor
    let onSelect: (TeamColor) -> Void
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Layout.spacing) {
            Text("Team Color")
                .font(.headline)
            HStack(spacing: Layout.circleSpacing) {
                ForEach(TeamColor.allCases) { color in
                    Button {
                        select(color)
                    } label: {
                        Circle()
                            .fill(color.gradient)
                            .frame(width: Layout.circleSize, height: Layout.circleSize)
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
