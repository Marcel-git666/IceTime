//
//  TeamsListView.swift
//  IceTime
//
//  Created by Marcel Mravec on 20.09.2026.
//


import SwiftUI

struct TeamsListView: View {
    @State private var viewModel = TeamsViewModel()
    @State private var isShowingNewTeamAlert = false
    @State private var newTeamName = ""
    @State private var isPresentingProfile = false
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationStack {
            List(viewModel.teams) { team in
                NavigationLink(value: team) {
                    VStack(alignment: .leading) {
                        Text(team.name)
                            .font(.headline)
                        Text(team.role == .owner ? "Owner" : "Participant")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .swipeActions {
                    if team.role == .owner {
                        Button(role: .destructive) {
                            Task { await viewModel.deleteTeam(team) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    Task { await viewModel.load() }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .teamShareAccepted)) { _ in
                Task { await viewModel.load() }
            }
            .refreshable {
                await viewModel.load()
            }
            .navigationDestination(for: Team.self) { team in
                TeamDetailView(team: team)
            }
            .navigationTitle("Teams")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        newTeamName = ""
                        isShowingNewTeamAlert = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(viewModel.isBusy)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isPresentingProfile = true
                    } label: {
                        Image(systemName: "person.crop.circle")
                    }
                }
            }
            .overlay {
                if viewModel.isBusy && viewModel.teams.isEmpty {
                    ProgressView()
                }
            }
            .task {
                await viewModel.load()
            }
            .alert("New Team", isPresented: $isShowingNewTeamAlert) {
                TextField("Team name", text: $newTeamName)
                Button("Cancel", role: .cancel) {}
                Button("Create") {
                    Task {
                        await viewModel.createTeam(name: newTeamName)
                    }
                }
            }
            .errorAlert($viewModel.errorMessage)
            .sheet(isPresented: $isPresentingProfile) {
                ProfileView()
            }
        }
    }
}

#Preview {
    TeamsListView()
}
