//
//  EventDetailView.swift
//  IceTime
//
//  Created by Marcel Mravec on 25.09.2026.
//


import SwiftUI

struct EventDetailView: View {
    let event: Event
    let team: Team
    let color: TeamColor
    let eventsViewModel: EventsViewModel
    let rosterViewModel: RosterViewModel
    @State private var isEditing = false

    /// The latest version from the view model, so edits show up immediately.
    private var currentEvent: Event {
        eventsViewModel.events.first { $0.id == event.id } ?? event
    }

    var body: some View {
        let lineup = eventsViewModel.lineup(for: currentEvent, roster: rosterViewModel.players)
        List {
            Section {
                Text(currentEvent.date, format: .dateTime.weekday(.wide).day().month().hour().minute())
                Text(currentEvent.location)
                    .foregroundStyle(.secondary)
            }
            playerSection("Goalies \(lineup.goalies.count)/\(currentEvent.goalieLimit)",
                          players: lineup.goalies, showsWhenEmpty: true)
            playerSection("Skaters \(lineup.skaters.count)/\(currentEvent.skaterLimit)",
                          players: lineup.skaters, showsWhenEmpty: true)
            playerSection("Substitutes", players: lineup.goalieSubs + lineup.skaterSubs, color: .orange)
            playerSection("Not going", players: lineup.notGoing)
            playerSection("Undecided", players: lineup.undecided)
        }
        .scrollContentBackground(.hidden)
        .background(color.background)
        .tint(color.accent)
        .navigationTitle("Event")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if team.role == .owner {
                Button("Edit") { isEditing = true }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditEventSheet(event: currentEvent) { updated in
                Task { await eventsViewModel.updateEvent(updated, in: team) }
            }
        }
        .refreshable {
            await rosterViewModel.load(for: team)
            await eventsViewModel.load(for: team)
        }
    }

    @ViewBuilder
    private func playerSection(
        _ title: String,
        players: [Player],
        color: Color = .primary,
        showsWhenEmpty: Bool = false
    ) -> some View {
        if showsWhenEmpty || !players.isEmpty {
            Section(title) {
                ForEach(players) { player in
                    HStack {
                        Text(player.name)
                            .foregroundStyle(color)
                        if player.isGoalie {
                            Text("Goalie")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        rsvpControl(for: player)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func rsvpControl(for player: Player) -> some View {
        let status = eventsViewModel.rsvp(of: player, for: currentEvent)?.status
        if team.role == .owner || rosterViewModel.isCurrentUser(player) {
            RSVPMenu(status: status) { option in
                Task { await eventsViewModel.setRSVP(option, for: player, event: currentEvent, in: team) }
            }
        } else {
            RSVPStatusIcon(status: status)
        }
    }
}
