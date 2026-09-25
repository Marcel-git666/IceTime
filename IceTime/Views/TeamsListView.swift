//
//  TeamsListView.swift
//  IceTime
//
//  Created by Marcel Mravec on 20.09.2026.
//


import SwiftUI
import CloudKit

struct TeamsListView: View {
    @State private var viewModel = TeamsViewModel()
    @State private var colorStore = TeamColorStore()
    @State private var isShowingNewTeamAlert = false
    @State private var newTeamName = ""
    @State private var isPresentingProfile = false
    @State private var isPresentingShareSheet = false
    @State private var colorPickerTeam: Team?
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            List(viewModel.teams) { team in
                NavigationLink(value: team) {
                    teamCard(team)
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(colorStore.color(for: team).gradient)
                )
                .listRowSeparator(.hidden)
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
            .listRowSpacing(12)
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
                .presentationDetents([.height(160)])
            }
        }
    }

    private func teamCard(_ team: Team) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(team.name)
                    .font(.title3.bold())
                Label(
                    team.role == .owner ? "Owner" : "Participant",
                    systemImage: team.role == .owner ? "crown.fill" : "person.fill"
                )
                .font(.caption)
                .opacity(0.85)
            }
            Spacer()
            teamMenu(team)
        }
        .foregroundStyle(.white)
        .padding(.vertical, 12)
    }

    private func teamMenu(_ team: Team) -> some View {
        Menu {
            if team.role == .owner {
                Button {
                    Task { await share(team) }
                } label: {
                    Label("Share Team", systemImage: "square.and.arrow.up")
                }
            }
            Button {
                colorPickerTeam = team
            } label: {
                Label("Change Color", systemImage: "paintpalette")
            }
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .font(.title2)
                .foregroundStyle(.white)
        }
        .buttonStyle(.borderless)
    }

    private func share(_ team: Team) async {
        await viewModel.prepareShare(for: team)
        if viewModel.share != nil {
            isPresentingShareSheet = true
        }
    }
}

#Preview {
    TeamsListView()
}
