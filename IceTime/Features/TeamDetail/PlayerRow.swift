//
//  PlayerRow.swift
//  IceTime
//
//  Created by Marcel Mravec on 25.09.2026.
//

import SwiftUI

/// One roster row: name, goalie tag, quick contact buttons, or Sync on my own row.
struct PlayerRow: View {
    let player: Player
    let isCurrentUser: Bool
    let showsEditIndicator: Bool
    let onSync: () -> Void

    var body: some View {
        HStack {
            Text(player.name)
            Spacer()
            if player.isGoalie {
                Text("Goalie")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if isCurrentUser {
                Button("Sync", systemImage: "arrow.clockwise", action: onSync)
                    .font(.caption)
                    .imageScale(.small)
                    .buttonStyle(.borderless)
            } else {
                if let url = player.phoneURL {
                    Link(destination: url) {
                        Label("Call \(player.name)", systemImage: "phone.fill")
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.borderless)
                }
                if let url = player.emailURL {
                    Link(destination: url) {
                        Label("Email \(player.name)", systemImage: "envelope.fill")
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.borderless)
                }
            }
            if showsEditIndicator {
                EditIndicator()
            }
        }
    }
}
