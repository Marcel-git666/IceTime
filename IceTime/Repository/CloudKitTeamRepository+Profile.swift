//
//  CloudKitTeamRepository+Profile.swift
//  IceTime
//
//  Created by Marcel Mravec on 19.09.2026.
//

import Foundation
import CloudKit

extension CloudKitTeamRepository {
    func fetchProfile() async throws -> Profile? {
        try await ensureAccountAvailable()
        
        let recordID = CKRecord.ID(recordName: RecordType.profile)
        
        do {
            let record = try await container.privateCloudDatabase.record(for: recordID)
            return Profile(
                firstName: record["firstName"] as? String ?? "",
                lastName: record["lastName"] as? String ?? "",
                isGoalie: (record["isGoalie"] as? Int ?? 0) != 0,
                phone: record["phone"] as? String,
                email: record["email"] as? String
            )
        } catch let error as CKError where error.code == .unknownItem { return nil }
    }
    
    func saveProfile(_ profile: Profile) async throws {
        try await ensureAccountAvailable()
        
        let recordID = CKRecord.ID(recordName: RecordType.profile)
        
        let record: CKRecord
        do {
            record = try await container.privateCloudDatabase.record(for: recordID)
        } catch let error as CKError where error.code == .unknownItem {
            record = CKRecord(recordType: RecordType.profile, recordID: recordID)
        }
        
        record["firstName"] = profile.firstName
        record["lastName"] = profile.lastName
        record["isGoalie"] = profile.isGoalie ? 1 : 0
        record["phone"] = profile.phone
        record["email"] = profile.email
        
        _ = try await container.privateCloudDatabase.save(record)
    }
}
