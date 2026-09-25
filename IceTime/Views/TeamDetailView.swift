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
            if team.role == .owner {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isPresentingAddPlayer = true
                    } label: {
                        Image(systemName: "person.badge.plus")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button { isPresentingAddEvent = true } label: {
                        Image(systemName: "calendar.badge.plus")
                    }
                }
            }
        }
        .errorAlert($rosterViewModel.errorMessage)
        .errorAlert($eventsViewModel.errorMessage)
        .errorAlert($detailViewModel.errorMessage)
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
            AddEventSheet { template, recurrence in
                Task {
                    await eventsViewModel.createEvents(from: template, recurrence: recurrence, to: team)
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
        .sheet(isPresented: $rosterViewModel.needsProfile) {
            ProfileView(message: "Add your name so teammates know who you are.")
        }
        .navigationDestination(for: Event.self) { event in
            EventDetailView(
                event: event,
                team: team,
                eventsViewModel: eventsViewModel,
                rosterViewModel: rosterViewModel
            )
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
            if !rosterViewModel.isCurrentUserOnRoster {
                Button {
                    Task { await rosterViewModel.addMyself(to: team) }
                } label: {
                    Label("Add myself", systemImage: "person.fill.badge.plus")
                }
            }
            ForEach(rosterViewModel.players) { player in
                playerRow(player)
                    .contextMenu {
                        if let phone = player.phone,
                           let url = URL(string: "tel:\(phone.filter { !$0.isWhitespace })") {
                            Link("Call \(phone)", destination: url)
                        }
                        if let email = player.email, let url = URL(string: "mailto:\(email)") {
                            Link("Email \(email)", destination: url)
                        }
                    }
            }
        }
    }
    
    @ViewBuilder
    private func playerRow(_ player: Player) -> some View {
        HStack {
            Text(player.name)
            Spacer()
            if player.isGoalie {
                Text("Goalie")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if !rosterViewModel.isCurrentUser(player) {
                if let phone = player.phone,
                   let url = URL(string: "tel:\(phone.filter { !$0.isWhitespace })") {
                    Link(destination: url) {
                        Image(systemName: "phone.fill")
                    }
                    .buttonStyle(.borderless)
                }
                if let email = player.email, let url = URL(string: "mailto:\(email)") {
                    Link(destination: url) {
                        Image(systemName: "envelope.fill")
                    }
                    .buttonStyle(.borderless)
                }
            }
            if rosterViewModel.isCurrentUser(player) {
                Button {
                    Task { await rosterViewModel.syncMyInfo(to: team) }
                } label: {
                    Label("Sync", systemImage: "arrow.clockwise")
                        .font(.caption)
                        .imageScale(.small)
                }
                .buttonStyle(.borderless)
                .tint(.blue)
            }
        }
        .listRowBackground(
            rosterViewModel.isCurrentUser(player) ? Color.yellow.opacity(0.3) : nil
        )
    }
    
    @ViewBuilder
    private var eventsSection: some View {
        Section("Events") {
            ForEach(eventsViewModel.events) { event in
                NavigationLink(value: event) {
                    eventRow(event)
                }
                .swipeActions {
                    if team.role == .owner {
                        Button(role: .destructive) {
                            Task { await eventsViewModel.deleteEvent(event, from: team) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button {
                            editingEvent = event
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func eventRow(_ event: Event) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(event.date, format: .dateTime.day().month().year().hour().minute())
                Text(event.location)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(lineupSummary(for: event))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if let me = rosterViewModel.currentPlayer {
                RSVPMenu(status: eventsViewModel.rsvp(of: me, for: event)?.status) { option in
                    Task { await eventsViewModel.setRSVP(option, for: me, event: event, in: team) }
                }
            }
        }
    }
    
    private func lineupSummary(for event: Event) -> String {
        let lineup = eventsViewModel.lineup(for: event, roster: rosterViewModel.players)
        let goalies = "Goalies \(lineup.goalies.count)/\(event.goalieLimit)"
        let skaters = "Skaters \(lineup.skaters.count)/\(event.skaterLimit)"
        var summary = "\(goalies) · \(skaters)"
        let subs = lineup.goalieSubs.count + lineup.skaterSubs.count
        if subs > 0 {
            summary += " · \(subs) subs"
        }
        return summary
    }
}

#Preview {
    NavigationStack {
        TeamDetailView(team: Team(id: "preview", name: "Preview Team", role: .owner))
    }
}
