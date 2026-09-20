//
//  CloudKitTeamRepository+Deletion.swift
//  IceTime
//
//  Created by Marcel Mravec on 19.09.2026.
//

import Foundation
import CloudKit

extension CloudKitTeamRepository {
    func deleteEvent(_ event: Event, in team: Team) async throws {
        throw RepositoryError.notImplemented("deleteEvent")
    }
    
    func deleteTeam(_ team: Team) async throws {
        guard team.role == .owner else {
            throw RepositoryError.teamNotFound
        }
        let resolved = try await resolve(team)
        _ = try await resolved.database.deleteRecordZone(withID: resolved.zoneID)
        clearCachedZone(forTeamID: team.id)
    }
}
