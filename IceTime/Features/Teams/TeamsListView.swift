//
//  TeamsListView.swift
//  IceTime
//
//  Created by Marcel Mravec on 20.09.2026.
//


import SwiftUI
import CloudKit

struct TeamsListView: View {
    @Environment(\.scenePhase) private var scenePhase

    @State private var viewModel = TeamsViewModel()
    @State private var colorStore = TeamColorStore()
    @State private var isShowingNewTeamAlert = false
    @State private var newTeamName = ""
    @State private var isPresentingProfile = false
    @State private var isPresentingShareSheet = false
    @State private var colorPickerTeam: Team?

    var body: some View {
        NavigationStack {
            List(viewModel.teams) { team in
                NavigationLink(value: team) {
                    TeamCard(
                        team: team,
                        onShare: { share(team) },
                        onChangeColor: { colorPickerTeam = team }
                    )
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: Design.cardCornerRadius)
                        .fill(colorStore.color(for: team).gradient)
                )
                .listRowSeparator(.hidden)
                .swipeActions {
                    if team.role == .owner {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            delete(team)
                        }
                    }
                }
            }
            .listRowSpacing(Design.cardSpacing)
            .navigationTitle("Teams")
            .navigationDestination(for: Team.self) { team in
                TeamDetailView(team: team, color: colorStore.color(for: team))
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("My Profile", systemImage: "person.crop.circle") {
                        isPresentingProfile = true
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("New Team", systemImage: "plus", action: showNewTeamAlert)
                        .disabled(viewModel.isBusy)
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
            .refreshable {
                await viewModel.load()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    Task { await viewModel.load() }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .teamShareAccepted)) { _ in
                Task { await viewModel.load() }
            }
            .onReceive(NotificationCenter.default.publisher(for: .teamShareAcceptFailed)) { notification in
                viewModel.errorMessage = notification.object as? String
            }
            .alert("New Team", isPresented: $isShowingNewTeamAlert) {
                TextField("Team name", text: $newTeamName)
                Button("Cancel", role: .cancel) {}
                Button("Create", action: createTeam)
            }
            .errorAlert($viewModel.errorMessage)
            .sheet(isPresented: $isPresentingProfile) {
                ProfileView()
            }
            .sheet(isPresented: $isPresentingShareSheet) {
                if let share = viewModel.share {
                    ShareSheet(
                        share: share,
                        container: CKContainer(identifier: CloudKitTeamRepository.containerID)
                    )
                }
            }
            .sheet(item: $colorPickerTeam) { team in
                TeamColorPicker(selected: colorStore.color(for: team)) { color in
                    colorStore.setColor(color, for: team)
                }
                .presentationDetents([.height(TeamColorPicker.sheetHeight)])
            }
        }
    }

    private func showNewTeamAlert() {
        newTeamName = ""
        isShowingNewTeamAlert = true
    }

    private func createTeam() {
        Task { await viewModel.createTeam(name: newTeamName) }
    }

    private func delete(_ team: Team) {
        Task { await viewModel.deleteTeam(team) }
    }

    private func share(_ team: Team) {
        Task {
            await viewModel.prepareShare(for: team)
            if viewModel.share != nil {
                isPresentingShareSheet = true
            }
        }
    }
}

#Preview {
    TeamsListView()
}
