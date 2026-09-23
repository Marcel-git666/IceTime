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
    
    init(repository: TeamRepository = CloudKitTeamRepository()) {
        self.repository = repository
    }
    
    var isCurrentUserOnRoster: Bool {
        players.contains { isCurrentUser($0) }
    }
    
    func load(for team: Team) async {
        isBusy = true
        defer { isBusy = false }
        do {
            players = try await repository.fetchRoster(for: team)
            currentUserRecordID = try await repository.currentUserRecordID()
        } catch {
            errorMessage = error.userMessage
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
            errorMessage = error.userMessage
        }
    }
    func addMyself(to team: Team) async {
        guard !isBusy, !isCurrentUserOnRoster else { return }
        isBusy = true
        defer { isBusy = false }
        do {
            let userRecordID = try await repository.currentUserRecordID()
            guard let profile = try await repository.fetchProfile(), !profile.displayName.isEmpty else {
                needsProfile = true
                return
            }
            let player = Player(name: profile.displayName, isGoalie: profile.isGoalie, userRecordID: userRecordID, phone: profile.phone, email: profile.email)
            try await repository.addPlayerToRoster(player, to: team)
            players.append(player)
            players.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        } catch {
            errorMessage = error.userMessage
        }
    }
    
    func syncMyInfo(to team: Team) async {
        guard !isBusy, var player = players.first(where: { isCurrentUser($0) }) else { return }
        isBusy = true
        defer { isBusy = false }
        do {
            let profile = try await repository.fetchProfile()
            if let name = profile?.displayName, !name.isEmpty {
                player.name = name
            }
            player.isGoalie = profile?.isGoalie ?? false
            player.phone = profile?.phone
            player.email = profile?.email
            try await repository.addPlayerToRoster(player, to: team)
            if let index = players.firstIndex(where: { $0.id == player.id }) {
                players[index] = player
            }
            players.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        } catch {
            errorMessage = error.userMessage
        }
    }
    
    
    func isCurrentUser(_ player: Player) -> Bool {
        guard let currentUserRecordID else { return false }
        return player.userRecordID == currentUserRecordID
    }
}
