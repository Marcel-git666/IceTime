//
//  TeamDetailView.swift
//  IceTime
//
//  Created by Marcel Mravec on 20.09.2026.
//


import SwiftUI
import CloudKit

struct TeamDetailView: View {
    @State private var isPresentingShareSheet = false
    @State private var isPresentingAddPlayer = false
    @State private var detailViewModel = TeamDetailViewModel()
    @State private var rosterViewModel = RosterViewModel()
    let team: Team
    
    var body: some View {
        List {
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
        .navigationTitle(team.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isPresentingAddPlayer = true
                } label: {
                    Image(systemName: "person.badge.plus")
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
        .task {
            await rosterViewModel.load(for: team)
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
    }
}

#Preview {
    NavigationStack {
        TeamDetailView(team: Team(id: "preview", name: "Preview Team", role: .owner))
    }
}
