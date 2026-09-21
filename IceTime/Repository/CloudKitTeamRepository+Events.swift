//
//  CloudKitTeamRepository+Events.swift
//  IceTime
//
//  Created by Marcel Mravec on 19.09.2026.
//

import Foundation
import CloudKit

extension CloudKitTeamRepository {
    func createEvent(_ event: Event, in team: Team) async throws {
        let resolved = try await resolve(team)
        let record = CKRecord(
            recordType: RecordType.event,
            recordID: CKRecord.ID(recordName: event.id.uuidString, zoneID: resolved.zoneID)
        )
        record["date"] = event.date
        record["location"] = event.location
        _ = try await resolved.database.save(record)
    }
    
    func fetchEvents(for team: Team) async throws -> [Event] {
        let records = try await fetchAllRecords(recordType: RecordType.event, in: team)
        return records.compactMap { try? event(from: $0) }
            .sorted { $0.date < $1.date }
    }
    
    func updateEvent(_ event: Event, in team: Team) async throws {
        guard team.role == .owner else {
            throw RepositoryError.teamNotFound
        }
        let resolved = try await resolve(team)
        let recordID = CKRecord.ID(recordName: event.id.uuidString, zoneID: resolved.zoneID)
        let record = try await resolved.database.record(for: recordID)
        record["date"] = event.date
        record["location"] = event.location
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
        return Event(id: uuid, date: date, location: location)
    }
}
