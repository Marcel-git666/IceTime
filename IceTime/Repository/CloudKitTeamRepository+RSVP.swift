//
//  CloudKitTeamRepository+RSVP.swift
//  IceTime
//
//  Created by Marcel Mravec on 19.09.2026.
//

import Foundation
import CloudKit

extension CloudKitTeamRepository {
    
    /// One answer per player per event: the record ID itself enforces uniqueness.
    func rsvpRecordID(eventID: UUID, playerID: UUID, in zoneID: CKRecordZone.ID) -> CKRecord.ID {
        CKRecord.ID(recordName: "\(eventID.uuidString)_\(playerID.uuidString)", zoneID: zoneID)
    }
    
    func submitRSVP(_ rsvp: RSVP, in team: Team) async throws {
        let resolved = try await resolve(team)
        let recordID = rsvpRecordID(eventID: rsvp.eventID, playerID: rsvp.playerID, in: resolved.zoneID)
        
        // Fresh local record, not fetched: .changedKeys skips the change-tag check,
        // so this creates the record or overwrites the existing one (last write wins).
        // respondedAt is not stored: the server's modificationDate is the source of truth for queue order
        let record = CKRecord(recordType: RecordType.rsvp, recordID: recordID)
        record["eventID"] = rsvp.eventID.uuidString
        record["playerID"] = rsvp.playerID.uuidString
        record["status"] = rsvp.status.rawValue
        
        let (saveResults, _) = try await resolved.database.modifyRecords(
            saving: [record],
            deleting: [],
            savePolicy: .changedKeys
        )
        _ = try saveResults[recordID]?.get()
    }
    
    func fetchRSVPs(for team: Team) async throws -> [RSVP] {
        let records = try await fetchAllRecords(recordType: RecordType.rsvp, in: team)
        return records.compactMap { try? rsvp(from: $0) }
    }
    
    private func rsvp(from record: CKRecord) throws -> RSVP {
        guard
            let eventID = (record["eventID"] as? String).flatMap(UUID.init(uuidString:)),
            let playerID = (record["playerID"] as? String).flatMap(UUID.init(uuidString:)),
            let status = (record["status"] as? String).flatMap(RSVPStatus.init(rawValue:)),
            let respondedAt = record.modificationDate
        else {
            throw RepositoryError.malformedRecord("RSVP \(record.recordID.recordName)")
        }
        return RSVP(playerID: playerID, eventID: eventID, status: status, respondedAt: respondedAt)
    }
}
