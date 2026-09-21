//
//  TeamDetailView.swift
//  IceTime
//
//  Created by Marcel Mravec on 20.09.2026.
//


import SwiftUI
import CloudKit

struct TeamDetailView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var isPresentingShareSheet = false
    @State private var isPresentingAddPlayer = false
    @State private var isPresentingAddEvent = false
    @State private var editingEvent: Event?
    @State private var detailViewModel = TeamDetailViewModel()
    @State private var rosterViewModel = RosterViewModel()
    @State private var eventsViewModel = EventsViewModel()
    let team: Team
    
    var body: some View {
        List {
            infoSection
            rosterSection
            eventsSection
        }
        .navigationTitle(team.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isPresentingAddPlayer = true
                } label: {
                    Image(systemName: "person.badge.plus")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isPresentingAddEvent = true
                } label: {
                    Image(systemName: "calendar.badge.plus")
                }
            }
        }
        .alert("Error", isPresented: Binding(
            get: { rosterViewModel.errorMessage != nil },
            set: { if !$0 { rosterViewModel.errorMessage = nil } }
        )) {
            Button("OK") { rosterViewModel.errorMessage = nil }
        } message: {
            Text(rosterViewModel.errorMessage ?? "")
        }
        .alert("Error", isPresented: Binding(
            get: { eventsViewModel.errorMessage != nil },
            set: { if !$0 { eventsViewModel.errorMessage = nil } }
        )) {
            Button("OK") { eventsViewModel.errorMessage = nil }
        } message: {
            Text(eventsViewModel.errorMessage ?? "")
        }
        .task {
            await rosterViewModel.load(for: team)
            await eventsViewModel.load(for: team)
        }
        .refreshable {
            await rosterViewModel.load(for: team)
            await eventsViewModel.load(for: team)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task {
                    await rosterViewModel.load(for: team)
                    await eventsViewModel.load(for: team)
                }
            }
        }
        .sheet(isPresented: $isPresentingShareSheet) {
            if let share = detailViewModel.share {
                ShareSheet(
                    share: share,
                    container: CKContainer(identifier: CloudKitTeamRepository.containerID)
                )
            }
        }
        .sheet(isPresented: $isPresentingAddPlayer) {
            AddPlayerSheet { name, isGoalie in
                Task {
                    await rosterViewModel.addPlayer(name: name, isGoalie: isGoalie, to: team)
                }
            }
        }
        .sheet(isPresented: $isPresentingAddEvent) {
            AddEventSheet { date, location, recurrence in
                Task {
                    await eventsViewModel.createEvents(startDate: date, location: location, recurrence: recurrence, to: team)
                }
            }
        }
        .sheet(item: $editingEvent) { event in
            EditEventSheet(event: event) { updated in
                Task {
                    await eventsViewModel.updateEvent(updated, in: team)
                }
            }
        }
    }
    
    @ViewBuilder
    private var infoSection: some View {
        Section {
            Text(team.role == .owner ? "Owner" : "Participant")
                .foregroundStyle(.secondary)
            if team.role == .owner {
                Button("Share Team") {
                    Task {
                        await detailViewModel.invite(team)
                        if detailViewModel.share != nil {
                            isPresentingShareSheet = true
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var rosterSection: some View {
        Section("Roster") {
            ForEach(rosterViewModel.players) { player in
                HStack {
                    Text(player.name)
                    if player.isGoalie {
                        Spacer()
                        Text("Goalie")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var eventsSection: some View {
        Section("Events") {
            ForEach(eventsViewModel.events) { event in
                Button {
                    if team.role == .owner {
                        editingEvent = event
                    }
                } label: {
                    VStack(alignment: .leading) {
                        Text(event.date, format: .dateTime.day().month().year().hour().minute())
                        Text(event.location)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .foregroundStyle(.primary)
                .swipeActions {
                    if team.role == .owner {
                        Button(role: .destructive) {
                            Task { await eventsViewModel.deleteEvent(event, from: team) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TeamDetailView(team: Team(id: "preview", name: "Preview Team", role: .owner))
    }
}
