//
//  TeamDetailView.swift
//  IceTime
//
//  Created by Marcel Mravec on 20.09.2026.
//


import SwiftUI

struct TeamDetailView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var isPresentingAddPlayer = false
    @State private var isPresentingAddEvent = false
    @State private var editingEvent: Event?
    @State private var editingPlayer: Player?
    @State private var rosterViewModel = RosterViewModel()
    @State private var eventsViewModel = EventsViewModel()
    @State private var selectedSection: TeamSection = .events
    @State private var isEditing = false
    let team: Team
    let color: TeamColor
    
    enum TeamSection: String, CaseIterable {
        case events = "Events"
        case roster = "Roster"
    }
    
    var body: some View {
        List {
            switch selectedSection {
            case .events:
                eventsSection
            case .roster:
                rosterSection
            }
        }
        // Our own state instead of EditButton's, so rows can show edit controls too
        .environment(\.editMode, .constant(isEditing ? .active : .inactive))
        .safeAreaInset(edge: .top) {
            Picker("Section", selection: $selectedSection) {
                ForEach(TeamSection.allCases, id: \.self) { section in
                    Text(section.rawValue).tag(section)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, 8)
            .background(.bar)
        }
        .scrollContentBackground(.hidden)
        .background(color.background)
        .tint(color.accent)
        .navigationTitle(team.name)
        .toolbar {
            if team.role == .owner {
                ToolbarItem(placement: .primaryAction) {
                    switch selectedSection {
                    case .events:
                        Button { isPresentingAddEvent = true } label: {
                            Image(systemName: "calendar.badge.plus")
                        }
                    case .roster:
                        Button { isPresentingAddPlayer = true } label: {
                            Image(systemName: "person.badge.plus")
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditing ? "Done" : "Edit") {
                        withAnimation { isEditing.toggle() }
                    }
                }
            }
        }
        .errorAlert($rosterViewModel.errorMessage)
        .errorAlert($eventsViewModel.errorMessage)
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
        .sheet(isPresented: $isPresentingAddPlayer) {
            PlayerSheet { name, isGoalie in
                Task {
                    await rosterViewModel.addPlayer(name: name, isGoalie: isGoalie, to: team)
                }
            }
        }
        .sheet(item: $editingPlayer) { player in
            PlayerSheet(player: player) { name, isGoalie in
                var updated = player
                updated.name = name
                updated.isGoalie = isGoalie
                Task {
                    await rosterViewModel.updatePlayer(updated, in: team)
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
                color: color,
                eventsViewModel: eventsViewModel,
                rosterViewModel: rosterViewModel
            )
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
                rosterRow(player)
                    .contextMenu {
                        if let phone = player.phone,
                           let url = URL(string: "tel:\(phone.filter { !$0.isWhitespace })") {
                            Link("Call \(phone)", destination: url)
                        }
                        if let email = player.email, let url = URL(string: "mailto:\(email)") {
                            Link("Email \(email)", destination: url)
                        }
                    }
                    .swipeActions {
                        if team.role == .owner {
                            Button(role: .destructive) {
                                Task { await rosterViewModel.deletePlayer(player, from: team) }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        if canEdit(player) {
                            Button {
                                editingPlayer = player
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                    .deleteDisabled(team.role != .owner)
            }
            .onDelete(perform: deletePlayers)
        }
    }

    /// The owner can edit guests; registered players' details come from their own profile.
    private func canEdit(_ player: Player) -> Bool {
        team.role == .owner && player.userRecordID == nil
    }

    /// Editable rows open the edit sheet on tap.
    @ViewBuilder
    private func rosterRow(_ player: Player) -> some View {
        if canEdit(player) {
            Button {
                editingPlayer = player
            } label: {
                HStack {
                    playerRow(player)
                    if isEditing {
                        editIndicator
                    }
                }
            }
            .foregroundStyle(.primary)
        } else {
            playerRow(player)
        }
    }

    private func deletePlayers(at offsets: IndexSet) {
        let players = offsets.map { rosterViewModel.players[$0] }
        Task {
            for player in players {
                await rosterViewModel.deletePlayer(player, from: team)
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
                .deleteDisabled(team.role != .owner)
            }
            .onDelete(perform: deleteEvents)
        }
    }

    private func deleteEvents(at offsets: IndexSet) {
        let events = offsets.map { eventsViewModel.events[$0] }
        Task {
            for event in events {
                await eventsViewModel.deleteEvent(event, from: team)
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
            if isEditing && team.role == .owner {
                Button {
                    editingEvent = event
                } label: {
                    editIndicator
                }
                .buttonStyle(.borderless)
            } else if let me = rosterViewModel.currentPlayer {
                RSVPMenu(status: eventsViewModel.rsvp(of: me, for: event)?.status) { option in
                    Task { await eventsViewModel.setRSVP(option, for: me, event: event, in: team) }
                }
            }
        }
    }

    /// Pencil shown on editable rows while the list is in edit mode.
    private var editIndicator: some View {
        Image(systemName: "pencil.circle.fill")
            .font(.title2)
            .foregroundStyle(.blue)
            .accessibilityLabel("Edit")
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
        TeamDetailView(team: Team(id: "preview", name: "Preview Team", role: .owner), color: .ocean)
    }
}
