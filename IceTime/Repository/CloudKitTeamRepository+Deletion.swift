//
//  CloudKitTeamRepository+Deletion.swift
//  IceTime
//
//  Created by Marcel Mravec on 19.09.2026.
//

import Foundation

extension CloudKitTeamRepository {
    func deleteEvent(_ event: Event, in team: Team) async throws {
        throw RepositoryError.notImplemented("deleteEvent")
    }
    
    func deleteTeam(_ team: Team) async throws {
        throw RepositoryError.notImplemented("deleteTeam")
    }
}
