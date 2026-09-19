//
//  CloudKitTeamRepository+Roster.swift
//  IceTime
//
//  Created by Marcel Mravec on 19.09.2026.
//

import Foundation

extension CloudKitTeamRepository {
    func fetchRoster(for team: Team) async throws -> [Player] {
        throw RepositoryError.notImplemented("fetchRoster")
    }
    
    func addPlayerToRoster(_ player: Player, to team: Team) async throws {
        throw RepositoryError.notImplemented("addPlayerToRoster")
    }
}
