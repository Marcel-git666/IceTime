//
//  CloudKitTeamRepository+RSVP.swift
//  IceTime
//
//  Created by Marcel Mravec on 19.09.2026.
//

import Foundation

extension CloudKitTeamRepository {
    func submitRSVP(_ rsvp: RSVP, in team: Team) async throws {
        throw RepositoryError.notImplemented("submitRSVP")
    }
    
    func fetchRSVPs(for eventID: UUID, in team: Team) async throws -> [RSVP] {
        throw RepositoryError.notImplemented("fetchRSVPs")
    }
}
