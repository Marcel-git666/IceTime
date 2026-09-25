//
//  CloudKitTeamRepository.swift
//  IceTime
//
//  Created by Marcel Mravec on 19.09.2026.
//


import Foundation
import CloudKit

final class CloudKitTeamRepository: TeamRepository {
    static let containerID = "iCloud.com.marcel.IceTime"
    static let teamZonePrefix = "Team-"
    
    let container: CKContainer
    
    init() {
        container = CKContainer(identifier: Self.containerID)
    }
    
    // MARK: Zone resolution — the heart of shared CloudKit
    struct ResolvedZone {
        let zoneID: CKRecordZone.ID
        let database: CKDatabase
    }
    
    enum RecordType {
        static let teamInfo = "TeamInfo"
        static let player = "Player"
        static let event = "Event"
        static let profile = "Profile"
        static let rsvp = "RSVP"
    }
    
    private var zoneCache: [String: CKRecordZone.ID] = [:]
    
    func resolve(_ team: Team) async throws -> ResolvedZone {
        let database = database(for: team.role)
        if let zoneID = zoneCache[team.id] {
            return ResolvedZone(zoneID: zoneID, database: database)
        }
        guard let zone = try await firstZone(named: team.id, in: database) else {
            throw RepositoryError.teamNotFound
        }
        zoneCache[team.id] = zone.zoneID
        return ResolvedZone(zoneID: zone.zoneID, database: database)
    }
    
    private func database(for role: TeamRole) -> CKDatabase {
        switch role {
        case .owner: return container.privateCloudDatabase
        case .participant: return container.sharedCloudDatabase
        }
    }
    
    private func firstZone(named name: String, in database: CKDatabase) async throws -> CKRecordZone? {
        do {
            let zones = try await database.allRecordZones()
            return zones.first { $0.zoneID.zoneName == name }
        } catch let error as CKError where error.code == .unknownItem {
            return nil
        }
    }
    
    func teamZones(in database: CKDatabase) async throws -> [CKRecordZone] {
        do {
            let zones = try await database.allRecordZones()
            return zones.filter { $0.zoneID.zoneName.hasPrefix(Self.teamZonePrefix) }
        } catch let error as CKError where error.code == .unknownItem {
            return []
        }
    }
    
    func ensureAccountAvailable() async throws {
        let status = try await container.accountStatus()
        guard status == .available else {
            throw RepositoryError.iCloudUnavailable
        }
    }
    
    func requireOwner(_ team: Team) throws {
        guard team.role == .owner else {
            throw RepositoryError.notOwner
        }
    }
    
    func cacheZone(_ zoneID: CKRecordZone.ID, forTeamID teamID: String) {
        zoneCache[teamID] = zoneID
    }
    
    func clearCachedZone(forTeamID teamID: String) {
        zoneCache[teamID] = nil
    }
    
    func fetchAllRecords(recordType: String, in team: Team) async throws -> [CKRecord] {
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
                // A record that fails to load on its own is skipped; the rest of the page still shows
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
