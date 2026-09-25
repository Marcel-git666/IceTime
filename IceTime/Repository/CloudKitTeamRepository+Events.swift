//
//  CloudKitTeamRepository+Events.swift
//  IceTime
//
//  Created by Marcel Mravec on 19.09.2026.
//

import Foundation
import CloudKit

extension CloudKitTeamRepository {
    func createEvents(_ events: [Event], in team: Team) async throws {
        try requireOwner(team)
        let resolved = try await resolve(team)
        
        let records = events.map { event in
            let record = CKRecord(
                recordType: RecordType.event,
                recordID: CKRecord.ID(recordName: event.id.uuidString, zoneID: resolved.zoneID)
            )
            apply(event, to: record)
            return record
        }
        
        // Atomic by default in a custom zone: the whole series is saved, or none of it.
        let (saveResults, _) = try await resolved.database.modifyRecords(saving: records, deleting: [])
        for result in saveResults.values {
            _ = try result.get()
        }
    }
    
    func fetchEvents(for team: Team) async throws -> [Event] {
        let records = try await fetchAllRecords(recordType: RecordType.event, in: team)
        return records.compactMap { try? event(from: $0) }
            .sorted { $0.date < $1.date }
    }
    
    func updateEvent(_ event: Event, in team: Team) async throws {
        try requireOwner(team)
        let resolved = try await resolve(team)
        let recordID = CKRecord.ID(recordName: event.id.uuidString, zoneID: resolved.zoneID)
        let record = try await resolved.database.record(for: recordID)
        apply(event, to: record)
        _ = try await resolved.database.save(record)
    }
    
    private func event(from record: CKRecord) throws -> Event {
        guard
            let uuid = UUID(uuidString: record.recordID.recordName),
            let date = record["date"] as? Date,
            let location = record["location"] as? String
        else {
            throw RepositoryError.malformedRecord("Event \(record.recordID.recordName)")
        }
        return Event(
            id: uuid,
            date: date,
            location: location,
            goalieLimit: record["goalieLimit"] as? Int ?? Event.defaultGoalieLimit,
            skaterLimit: record["skaterLimit"] as? Int ?? Event.defaultSkaterLimit
        )
    }
    
    private func apply(_ event: Event, to record: CKRecord) {
        record["date"] = event.date
        record["location"] = event.location
        record["goalieLimit"] = event.goalieLimit
        record["skaterLimit"] = event.skaterLimit
    }
}
