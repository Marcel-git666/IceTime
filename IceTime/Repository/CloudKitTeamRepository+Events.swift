//
//  CloudKitTeamRepository+Events.swift
//  IceTime
//
//  Created by Marcel Mravec on 19.09.2026.
//

import Foundation

extension CloudKitTeamRepository {
    func createEvent(_ event: Event, in team: Team) async throws {
        throw RepositoryError.notImplemented("createEvent")
    }
    
    func fetchEvents(for team: Team) async throws -> [Event] {
        throw RepositoryError.notImplemented("fetchEvents")
    }
}
