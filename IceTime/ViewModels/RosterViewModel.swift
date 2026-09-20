//
//  RosterViewModel.swift
//  IceTime
//
//  Created by Marcel Mravec on 20.09.2026.
//


import Foundation
import Observation

@Observable
final class RosterViewModel {
    private(set) var players: [Player] = []
    private(set) var isBusy = false
    var errorMessage: String?
    
    private let repository: TeamRepository
    
    init(repository: TeamRepository = CloudKitTeamRepository()) {
        self.repository = repository
    }
    
    func load(for team: Team) async {
        isBusy = true
        defer { isBusy = false }
        do {
            players = try await repository.fetchRoster(for: team)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func addPlayer(name: String, isGoalie: Bool, to team: Team) async {
        guard !isBusy else { return }
        isBusy = true
        defer { isBusy = false }
        do {
            let player = Player(name: name, isGoalie: isGoalie)
            try await repository.addPlayerToRoster(player, to: team)
            players.append(player)
            players.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
