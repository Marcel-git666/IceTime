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
    private(set) var currentUserRecordID: String?
    var needsProfile = false
    var errorMessage: String?
    
    private let repository: TeamRepository
    
    init(repository: TeamRepository = CloudKitTeamRepository.shared) {
        self.repository = repository
    }
    
    var currentPlayer: Player? {
        players.first { isCurrentUser($0) }
    }
    
    var isCurrentUserOnRoster: Bool {
        currentPlayer != nil
    }
    
    func load(for team: Team) async {
        isBusy = true
        defer { isBusy = false }
        do {
            players = try await repository.fetchRoster(for: team)
            currentUserRecordID = try await repository.currentUserRecordID()
        } catch {
            if !error.isCancellation {
                errorMessage = error.userMessage
            }
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
            players.sort()
        } catch {
            errorMessage = error.userMessage
        }
    }
    func updatePlayer(_ player: Player, in team: Team) async {
        guard !isBusy else { return }
        isBusy = true
        defer { isBusy = false }
        do {
            // addPlayerToRoster is an upsert: it updates the existing record with the same ID
            try await repository.addPlayerToRoster(player, to: team)
            if let index = players.firstIndex(where: { $0.id == player.id }) {
                players[index] = player
            }
            players.sort()
        } catch {
            errorMessage = error.userMessage
        }
    }

    func addMyself(to team: Team) async {
        guard !isBusy, !isCurrentUserOnRoster else { return }
        isBusy = true
        defer { isBusy = false }
        do {
            let userRecordID = try await repository.currentUserRecordID()
            // load() may have failed to get the user ID, which made the button appear for someone already on the roster
            currentUserRecordID = userRecordID
            guard !players.contains(where: { $0.userRecordID == userRecordID }) else { return }
            guard let profile = try await repository.fetchProfile(), !profile.displayName.isEmpty else {
                needsProfile = true
                return
            }
            let player = Player(name: profile.displayName, isGoalie: profile.isGoalie, userRecordID: userRecordID, phone: profile.phone, email: profile.email)
            try await repository.addPlayerToRoster(player, to: team)
            players.append(player)
            players.sort()
        } catch {
            errorMessage = error.userMessage
        }
    }
    
    func syncMyInfo(to team: Team) async {
        guard !isBusy, var player = players.first(where: { isCurrentUser($0) }) else { return }
        isBusy = true
        defer { isBusy = false }
        do {
            guard let profile = try await repository.fetchProfile() else {
                needsProfile = true
                return
            }
            if !profile.displayName.isEmpty {
                player.name = profile.displayName
            }
            player.isGoalie = profile.isGoalie
            player.phone = profile.phone
            player.email = profile.email
            try await repository.addPlayerToRoster(player, to: team)
            if let index = players.firstIndex(where: { $0.id == player.id }) {
                players[index] = player
            }
            players.sort()
        } catch {
            errorMessage = error.userMessage
        }
    }
    
    func isCurrentUser(_ player: Player) -> Bool {
        guard let currentUserRecordID else { return false }
        return player.userRecordID == currentUserRecordID
    }
    
    func deletePlayer(_ player: Player, from team: Team) async {
        guard !isBusy else { return }
        isBusy = true
        defer { isBusy = false }
        do {
            try await repository.deletePlayer(player, from: team)
            players.removeAll { $0.id == player.id }
        } catch {
            errorMessage = error.userMessage
        }
    }
}
