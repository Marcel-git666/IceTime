//
//  LineupSection.swift
//  IceTime
//
//  Created by Marcel Mravec on 25.09.2026.
//

import SwiftUI

/// One group of the event lineup (goalies, skaters, substitutes...) with each player's answer.
struct LineupSection: View {
    let title: String
    let players: [Player]
    var isSubstitute = false
    var showsWhenEmpty = false
    let event: Event
    let team: Team
    let eventsViewModel: EventsViewModel
    let rosterViewModel: RosterViewModel

    var body: some View {
        if showsWhenEmpty || !players.isEmpty {
            Section(title) {
                ForEach(players) { player in
                    HStack {
                        Text(player.name)
                            .foregroundStyle(isSubstitute ? .orange : .primary)
                        if player.isGoalie {
                            Text("Goalie")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if canReply(for: player) {
                            RSVPMenu(status: status(of: player)) { status in
                                reply(status, for: player)
                            }
                        } else {
                            RSVPStatusIcon(status: status(of: player))
                        }
                    }
                    .translucentRowBackground()
                }
            }
        }
    }

    /// The owner can answer for anyone (guests have no app); everyone else only for themselves.
    private func canReply(for player: Player) -> Bool {
        team.role == .owner || rosterViewModel.isCurrentUser(player)
    }

    private func status(of player: Player) -> RSVPStatus? {
        eventsViewModel.rsvp(of: player, for: event)?.status
    }

    private func reply(_ status: RSVPStatus, for player: Player) {
        Task { await eventsViewModel.setRSVP(status, for: player, event: event, in: team) }
    }
}
