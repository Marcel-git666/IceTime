//
//  CloudKitTeamRepository+Teams.swift
//  IceTime
//
//  Created by Marcel Mravec on 19.09.2026.
//

import Foundation
import CloudKit

extension CloudKitTeamRepository {
    func fetchTeams() async throws -> [Team] {
        try await ensureAccountAvailable()
        var teams: [Team] = []
        
        for zone in try await teamZones(in: container.privateCloudDatabase) {
            cacheZone(zone.zoneID, forTeamID: zone.zoneID.zoneName)
            let name = try await teamName(for: zone.zoneID, in: container.privateCloudDatabase)
            teams.append(Team(id: zone.zoneID.zoneName, name: name, role: .owner))
        }

        for zone in try await teamZones(in: container.sharedCloudDatabase) {
              cacheZone(zone.zoneID, forTeamID: zone.zoneID.zoneName)
              let name = try await teamName(for: zone.zoneID, in: container.sharedCloudDatabase)
              teams.append(Team(id: zone.zoneID.zoneName, name: name, role: .participant))
          }
        
        return teams
    }
    
    private func teamName(for zoneID: CKRecordZone.ID, in database: CKDatabase) async throws -> String {
        let recordID = CKRecord.ID(recordName: RecordType.teamInfo, zoneID: zoneID)
        if let record = try? await database.record(for: recordID), let name = record["name"] as? String {
            return name
        }
        return "Unnamed Team"
    }
    
    func createTeam(name: String) async throws -> Team {
        try await ensureAccountAvailable()
        
        let zoneName = "\(Self.teamZonePrefix)\(UUID().uuidString)"
        let zone = CKRecordZone(zoneName: zoneName)
        _ = try await container.privateCloudDatabase.save(zone)
        cacheZone(zone.zoneID, forTeamID: zoneName)
        
        let infoRecord = CKRecord(
            recordType: RecordType.teamInfo,
            recordID: CKRecord.ID(recordName: RecordType.teamInfo, zoneID: zone.zoneID)
        )
        infoRecord["name"] = name
        _ = try await container.privateCloudDatabase.save(infoRecord)
        
        return Team(id: zoneName, name: name, role: .owner)
    }
    
    func currentUserRecordID() async throws -> String {
        try await ensureAccountAvailable()
        return try await container.userRecordID().recordName
    }
    
    func shareTeam(_ team: Team) async throws -> CKShare {
        guard team.role == .owner else {
            throw RepositoryError.teamNotFound
        }
        let resolved = try await resolve(team)
        
        let shareRecordID = CKRecord.ID(recordName: CKRecordNameZoneWideShare, zoneID: resolved.zoneID)
        if let existing = try? await resolved.database.record(for: shareRecordID) as? CKShare {
            return existing
        }
        
        let share = CKShare(recordZoneID: resolved.zoneID)
        share[CKShare.SystemFieldKey.title] = team.name
        guard let saved = try await resolved.database.save(share) as? CKShare else {
            throw RepositoryError.malformedRecord("save(share) did not return a CKShare")
        }
        return saved
    }
}

