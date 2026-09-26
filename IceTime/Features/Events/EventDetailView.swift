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

    @State private var isPresentingEdit = false

    /// The latest version from the view model, so edits show up immediately.
    private var currentEvent: Event {
        eventsViewModel.events.first { $0.id == event.id } ?? event
    }

    var body: some View {
        let lineup = eventsViewModel.lineup(for: currentEvent, roster: rosterViewModel.players)
        List {
            Section {
                Group {
                    Text(currentEvent.date, format: .dateTime.weekday(.wide).day().month().hour().minute())
                    Text(currentEvent.location)
                        .foregroundStyle(.secondary)
                }
                .translucentRowBackground()
            }
            section("Goalies \(lineup.goalies.count)/\(currentEvent.goalieLimit)",
                    players: lineup.goalies, showsWhenEmpty: true)
            section("Skaters \(lineup.skaters.count)/\(currentEvent.skaterLimit)",
                    players: lineup.skaters, showsWhenEmpty: true)
            section("Substitutes", players: lineup.goalieSubs + lineup.skaterSubs, isSubstitute: true)
            section("Not going", players: lineup.notGoing)
            section("Undecided", players: lineup.undecided)
        }
        .scrollContentBackground(.hidden)
        .background(color.background)
        .tint(color.accent)
        .navigationTitle("Event")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .bottomBar)
        .toolbar {
            if team.role == .owner {
                Button("Edit") {
                    isPresentingEdit = true
                }
            }
        }
        .sheet(isPresented: $isPresentingEdit) {
            EditEventSheet(event: currentEvent, onSave: save)
        }
        .refreshable {
            await rosterViewModel.load(for: team)
            await eventsViewModel.load(for: team)
        }
    }

    /// Fills in the parameters every lineup section shares.
    private func section(
        _ title: String,
        players: [Player],
        isSubstitute: Bool = false,
        showsWhenEmpty: Bool = false
    ) -> LineupSection {
        LineupSection(
            title: title,
            players: players,
            isSubstitute: isSubstitute,
            showsWhenEmpty: showsWhenEmpty,
            event: currentEvent,
            team: team,
            eventsViewModel: eventsViewModel,
            rosterViewModel: rosterViewModel
        )
    }

    private func save(_ event: Event) {
        Task { await eventsViewModel.updateEvent(event, in: team) }
    }
}
