//
//  TeamColor.swift
//  IceTime
//
//  Created by Marcel Mravec on 25.09.2026.
//


import SwiftUI

/// Color templates for team cards. Each player picks their own; the choice isn't shared with the team.
enum TeamColor: String, CaseIterable, Identifiable {
    case ocean
    case fire
    case forest
    case grape
    case sunset
    case graphite

    var id: Self { self }

    var gradient: LinearGradient {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var colors: [Color] {
        switch self {
        case .ocean: [.blue, .indigo]
        case .fire: [.red, .orange]
        case .forest: [.green, .teal]
        case .grape: [.purple, .pink]
        case .sunset: [.orange, .pink]
        case .graphite: [.gray, .black]
        }
    }

    /// A stable default until the player picks a color, so cards don't all look the same.
    /// `String.hashValue` can't be used here: Swift changes it on every launch.
    static func defaultColor(for team: Team) -> TeamColor {
        let sum = team.id.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return allCases[sum % allCases.count]
    }
}

/// A row of color circles; tapping one picks it and closes the sheet.
struct TeamColorPicker: View {
    @Environment(\.dismiss) private var dismiss
    let selected: TeamColor
    let onSelect: (TeamColor) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Team Color")
                .font(.headline)
            HStack(spacing: 14) {
                ForEach(TeamColor.allCases) { color in
                    Button {
                        onSelect(color)
                        dismiss()
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
}
