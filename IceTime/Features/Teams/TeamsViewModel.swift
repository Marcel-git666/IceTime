//
//  TeamsViewModel.swift
//  IceTime
//
//  Created by Marcel Mravec on 20.09.2026.
//


import Foundation
import CloudKit
import Observation

@Observable
final class TeamsViewModel {
    private(set) var teams: [Team] = []
    private(set) var isBusy = false
    var errorMessage: String?
    var share: CKShare?
    
    private let repository: TeamRepository
    
    init(repository: TeamRepository = CloudKitTeamRepository.shared) {
        self.repository = repository
    }
    
    func load() async {
        isBusy = true
        defer { isBusy = false }
        do {
            teams = try await repository.fetchTeams()
        } catch {
            errorMessage = error.userMessage
        }
    }
    
    func createTeam(name: String) async {
        guard !isBusy else { return }
        isBusy = true
        defer { isBusy = false }
        do {
            let team = try await repository.createTeam(name: name)
            teams.append(team)
        } catch {
            errorMessage = error.userMessage
        }
    }
    
    func prepareShare(for team: Team) async {
        guard !isBusy else { return }
        isBusy = true
        defer { isBusy = false }
        do {
            share = try await repository.shareTeam(team)
        } catch {
            errorMessage = error.userMessage
        }
    }

    func deleteTeam(_ team: Team) async {
        guard !isBusy else { return }
        isBusy = true
        defer { isBusy = false }
        do {
            try await repository.deleteTeam(team)
            teams.removeAll { $0.id == team.id }
        } catch {
            errorMessage = error.userMessage
        }
    }
}
