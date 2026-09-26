//
//  TeamCard.swift
//  IceTime
//
//  Created by Marcel Mravec on 25.09.2026.
//

import SwiftUI

/// A team in the teams list: name, role, and a menu for sharing and picking a color.
struct TeamCard: View {
    private enum Layout {
        /// Makes the card taller than a plain list row.
        static let verticalPadding = 12.0
    }
    
    let team: Team
    let onShare: () -> Void
    let onChangeColor: () -> Void
    
    private var isOwner: Bool {
        team.role == .owner
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(team.name)
                    .font(.title3.bold())
                Label(isOwner ? "Owner" : "Participant", systemImage: isOwner ? "crown.fill" : "person.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Menu("Team Options", systemImage: "ellipsis.circle.fill") {
                if isOwner {
                    Button("Share Team", systemImage: "square.and.arrow.up", action: onShare)
                }
                Button("Change Color", systemImage: "paintpalette", action: onChangeColor)
            }
            .labelStyle(.iconOnly)
            .font(.title2)
            .buttonStyle(.borderless)
        }
        .foregroundStyle(.white)
        .padding(.vertical, Layout.verticalPadding)
    }
}
