//
//  TeamDetailView.swift
//  IceTime
//
//  Created by Marcel Mravec on 20.09.2026.
//


import SwiftUI

struct TeamDetailView: View {
    let team: Team
    let color: TeamColor

    @Environment(\.scenePhase) private var scenePhase

    @State private var rosterViewModel = RosterViewModel()
    @State private var eventsViewModel = EventsViewModel()
    @State private var selectedSection: TeamSection = .events
    @State private var isEditing = false
    @State private var isPresentingAddEvent = false
    @State private var isPresentingAddPlayer = false
    @State private var editingEvent: Event?
    @State private var editingPlayer: Player?

    var body: some View {
        List {
            switch selectedSection {
            case .events:
                EventsSection(
                    team: team,
                    isEditing: isEditing,
                    eventsViewModel: eventsViewModel,
                    rosterViewModel: rosterViewModel,
                    editingEvent: $editingEvent
                )
            case .roster:
                RosterSection(
                    team: team,
                    isEditing: isEditing,
                    rosterViewModel: rosterViewModel,
                    editingPlayer: $editingPlayer
                )
            }
        }
        // Our own state instead of EditButton's, so rows can show edit controls too
        .environment(\.editMode, .constant(isEditing ? .active : .inactive))
        .scrollContentBackground(.hidden)
        .background(color.background)
        .tint(color.accent)
        .navigationTitle(team.name)
        .toolbar {
            ToolbarItem(placement: .status) {
                Picker("Section", selection: $selectedSection) {
                    ForEach(TeamSection.allCases) { section in
                        Text(section.rawValue).tag(section)
                    }
                }
                .pickerStyle(.segmented)
                .fixedSize()
                .glassEffect(.regular.tint(color.accent.opacity(0.3)))
            }
            .sharedBackgroundVisibility(.hidden)
            if team.role == .owner {
                ToolbarItem(placement: .primaryAction) {
                    switch selectedSection {
                    case .events:
                        Button("Add Event", systemImage: "calendar.badge.plus") {
                            isPresentingAddEvent = true
                        }
                    case .roster:
                        Button("Add Player", systemImage: "person.badge.plus") {
                            isPresentingAddPlayer = true
                        }
                    }
                }
                .sharedBackgroundVisibility(.hidden)
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditing ? "Done" : "Edit", action: toggleEditing)
                }
                .sharedBackgroundVisibility(.hidden)
            }
        }
        .errorAlert($rosterViewModel.errorMessage)
        .errorAlert($eventsViewModel.errorMessage)
        .task {
            await reload()
        }
        .refreshable {
            await reload()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task { await reload() }
            }
        }
        .sheet(isPresented: $isPresentingAddEvent) {
            AddEventSheet(onAdd: createEvents)
        }
        .sheet(item: $editingEvent) { event in
            EditEventSheet(event: event, onSave: updateEvent)
        }
        .sheet(isPresented: $isPresentingAddPlayer) {
            PlayerSheet(onSave: addPlayer)
        }
        .sheet(item: $editingPlayer) { player in
            PlayerSheet(player: player) { name, isGoalie in
                update(player, name: name, isGoalie: isGoalie)
            }
        }
        .sheet(isPresented: $rosterViewModel.needsProfile) {
            ProfileView(message: "Add your name so teammates know who you are.")
        }
        .navigationDestination(for: Event.self) { event in
            EventDetailView(
                event: event,
                team: team,
                color: color,
                eventsViewModel: eventsViewModel,
                rosterViewModel: rosterViewModel
            )
        }
    }

    /// Loads both, because the event summaries need the roster.
    private func reload() async {
        await rosterViewModel.load(for: team)
        await eventsViewModel.load(for: team)
    }

    private func toggleEditing() {
        withAnimation {
            isEditing.toggle()
        }
    }

    private func createEvents(from template: Event, recurrence: Recurrence) {
        Task { await eventsViewModel.createEvents(from: template, recurrence: recurrence, to: team) }
    }

    private func updateEvent(_ event: Event) {
        Task { await eventsViewModel.updateEvent(event, in: team) }
    }

    private func addPlayer(name: String, isGoalie: Bool) {
        Task { await rosterViewModel.addPlayer(name: name, isGoalie: isGoalie, to: team) }
    }

    private func update(_ player: Player, name: String, isGoalie: Bool) {
        var updated = player
        updated.name = name
        updated.isGoalie = isGoalie
        Task { await rosterViewModel.updatePlayer(updated, in: team) }
    }
}

#Preview {
    NavigationStack {
        TeamDetailView(team: Team(id: "preview", name: "Preview Team", role: .owner), color: .ocean)
    }
}
