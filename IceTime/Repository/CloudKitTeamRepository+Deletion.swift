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
        try requireOwner(team)
        let resolved = try await resolve(team)
        
        let eventRecordID = CKRecord.ID(recordName: event.id.uuidString, zoneID: resolved.zoneID)
        let rsvpRecordIDs = try await fetchRSVPs(for: team)
            .filter { $0.eventID == event.id }
            .map { rsvpRecordID(eventID: $0.eventID, playerID: $0.playerID, in: resolved.zoneID) }
        
        // Atomic by default in a custom zone: the event and its RSVPs go together or not at all.
        let (_, deleteResults) = try await resolved.database.modifyRecords(
            saving: [],
            deleting: [eventRecordID] + rsvpRecordIDs
        )
        for result in deleteResults.values {
            try result.get()
        }
    }
    
    func deleteTeam(_ team: Team) async throws {
        try requireOwner(team)
        let resolved = try await resolve(team)
        _ = try await resolved.database.deleteRecordZone(withID: resolved.zoneID)
        clearCachedZone(forTeamID: team.id)
    }
    
    func deletePlayer(_ player: Player, from team: Team) async throws {
        try requireOwner(team)
        let resolved = try await resolve(team)
        
        let playerRecordID = CKRecord.ID(recordName: player.id.uuidString, zoneID: resolved.zoneID)
        let rsvpRecordIDs = try await fetchRSVPs(for: team)
            .filter { $0.playerID == player.id }
            .map { rsvpRecordID(eventID: $0.eventID, playerID: $0.playerID, in: resolved.zoneID) }
        
        // The player and all their answers go together, or not at all.
        let (_, deleteResults) = try await resolved.database.modifyRecords(
            saving: [],
            deleting: [playerRecordID] + rsvpRecordIDs
        )
        for result in deleteResults.values {
            try result.get()
        }
    }
}
