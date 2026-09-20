//
//  CloudKitTeamRepository+Roster.swift
//  IceTime
//
//  Created by Marcel Mravec on 19.09.2026.
//

import Foundation
import CloudKit

extension CloudKitTeamRepository {
    func fetchRoster(for team: Team) async throws -> [Player] {
        let records = try await fetchAllRecords(recordType: "Player", in: team)
        return records.compactMap { try? player(from: $0) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    func addPlayerToRoster(_ player: Player, to team: Team) async throws {
        let resolved = try await resolve(team)
        let recordID = CKRecord.ID(recordName: player.id.uuidString, zoneID: resolved.zoneID)
        
        let record: CKRecord
        do {
            record = try await resolved.database.record(for: recordID)
        } catch let error as CKError where error.code == .unknownItem {
            record = CKRecord(recordType: "Player", recordID: recordID)
        }
        
        record["name"] = player.name
        record["isGoalie"] = player.isGoalie ? 1 : 0
        record["userRecordID"] = player.userRecordID
        _ = try await resolved.database.save(record)
    }
    
    private func player(from record: CKRecord) throws -> Player {
        guard
            let uuid = UUID(uuidString: record.recordID.recordName),
            let name = record["name"] as? String,
            let goalie = record["isGoalie"] as? Int
        else {
            throw RepositoryError.malformedRecord("Player \(record.recordID.recordName)")
        }
        return Player(
            id: uuid,
            name: name,
            isGoalie: goalie != 0,
            userRecordID: record["userRecordID"] as? String
        )
    }
    
    private func fetchAllRecords(recordType: String, in team: Team) async throws -> [CKRecord] {
        let resolved = try await resolve(team)
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        
        var out: [CKRecord] = []
        var cursor: CKQueryOperation.Cursor?
        
        do {
            repeat {
                let page: (matchResults: [(CKRecord.ID, Result<CKRecord, Error>)],
                           queryCursor: CKQueryOperation.Cursor?)
                if let cursor {
                    page = try await resolved.database.records(continuingMatchFrom: cursor)
                } else {
                    page = try await resolved.database.records(
                        matching: query,
                        inZoneWith: resolved.zoneID,
                        desiredKeys: nil,
                        resultsLimit: CKQueryOperation.maximumResults
                    )
                }
                for (_, result) in page.matchResults {
                    if let record = try? result.get() { out.append(record) }
                }
                cursor = page.queryCursor
            } while cursor != nil
        } catch let error as CKError where error.code == .unknownItem {
            return []
        }
        return out
    }
}
