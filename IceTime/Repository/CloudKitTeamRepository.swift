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
    
    func cacheZone(_ zoneID: CKRecordZone.ID, forTeamID teamID: String) {
        zoneCache[teamID] = zoneID
    }
}
