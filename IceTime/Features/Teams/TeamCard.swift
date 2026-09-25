//
//  TeamCard.swift
//  IceTime
//
//  Created by Marcel Mravec on 25.09.2026.
//

import SwiftUI

/// A team in the teams list: name, role, and a menu for sharing and picking a color.
struct TeamCard: View {
    let team: Team
    let onShare: () -> Void
    let onChangeColor: () -> Void

    private var isOwner: Bool {
        team.role == .owner
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(team.name)
                    .font(.title3.bold())
                Label(isOwner ? "Owner" : "Participant", systemImage: isOwner ? "crown.fill" : "person.fill")
                    .font(.caption)
                    .opacity(0.85)
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
        .padding(.vertical, 12)
    }
}
