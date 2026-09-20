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
    @State private var viewModel = TeamDetailViewModel()
    let team: Team
    
    var body: some View {
        VStack(spacing: 16) {
            Text(team.name)
                .font(.largeTitle)
            Text(team.role == .owner ? "Owner" : "Participant")
                .foregroundStyle(.secondary)
            if team.role == .owner {
                Button("Share Team") {
                    Task {
                        await viewModel.invite(team)
                        if viewModel.share != nil {
                            isPresentingShareSheet = true
                        }
                    }
                }
            }
        }
        .navigationTitle(team.name)
        .sheet(isPresented: $isPresentingShareSheet) {
            if let share = viewModel.share {
                ShareSheet(
                    share: share,
                    container: CKContainer(identifier: CloudKitTeamRepository.containerID)
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        TeamDetailView(team: Team(id: "preview", name: "Preview Team", role: .owner))
    }
}
