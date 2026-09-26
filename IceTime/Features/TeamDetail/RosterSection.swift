//
//  RosterSection.swift
//  IceTime
//
//  Created by Marcel Mravec on 25.09.2026.
//

import SwiftUI

/// The team roster: join button, contact actions, and owner-only guest editing and removal.
struct RosterSection: View {
    let team: Team
    let isEditing: Bool
    let rosterViewModel: RosterViewModel
    @Binding var editingPlayer: Player?

    private var isOwner: Bool {
        team.role == .owner
    }

    var body: some View {
        Section {
            if !rosterViewModel.isCurrentUserOnRoster {
                Button("Add myself", systemImage: "person.fill.badge.plus", action: addMyself)
            }
            ForEach(rosterViewModel.players) { player in
                Group {
                    if canEdit(player) {
                        // Guests open the edit sheet on tap
                        Button {
                            editingPlayer = player
                        } label: {
                            playerRow(for: player)
                        }
                        .foregroundStyle(.primary)
                    } else {
                        playerRow(for: player)
                    }
                }
                .contextMenu {
                    if let phone = player.phone, let url = player.phoneURL {
                        Link("Call \(phone)", destination: url)
                    }
                    if let email = player.email, let url = player.emailURL {
                        Link("Email \(email)", destination: url)
                    }
                }
                .swipeActions {
                    if isOwner {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            delete(player)
                        }
                    }
                    if canEdit(player) {
                        Button("Edit", systemImage: "pencil") {
                            editingPlayer = player
                        }
                        .tint(.blue)
                    }
                }
                .deleteDisabled(!isOwner)
                .listRowBackground(
                    Rectangle().fill(
                        rosterViewModel.isCurrentUser(player)
                        ? AnyShapeStyle(.tint.opacity(Design.currentUserHighlightOpacity))
                        : AnyShapeStyle(.thinMaterial)
                    )
                )
            }
            .onDelete(perform: deletePlayers)
        }
    }

    private func playerRow(for player: Player) -> PlayerRow {
        PlayerRow(
            player: player,
            isCurrentUser: rosterViewModel.isCurrentUser(player),
            showsEditIndicator: isEditing && canEdit(player),
            onSync: syncMyInfo
        )
    }

    /// The owner can edit guests; registered players' details come from their own profile.
    private func canEdit(_ player: Player) -> Bool {
        isOwner && player.userRecordID == nil
    }

    private func addMyself() {
        Task { await rosterViewModel.addMyself(to: team) }
    }

    private func syncMyInfo() {
        Task { await rosterViewModel.syncMyInfo(to: team) }
    }

    private func delete(_ player: Player) {
        Task { await rosterViewModel.deletePlayer(player, from: team) }
    }

    private func deletePlayers(at offsets: IndexSet) {
        // Turn indexes into players right away: the array may change while deleting
        let players = offsets.map { rosterViewModel.players[$0] }
        Task {
            for player in players {
                await rosterViewModel.deletePlayer(player, from: team)
            }
        }
    }
}
