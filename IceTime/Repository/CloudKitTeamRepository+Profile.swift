//
//  CloudKitTeamRepository+Profile.swift
//  IceTime
//
//  Created by Marcel Mravec on 19.09.2026.
//

import Foundation

extension CloudKitTeamRepository {
    func fetchProfile() async throws -> Profile? {
        throw RepositoryError.notImplemented("fetchProfile")
    }
    
    func saveProfile(_ profile: Profile) async throws {
        throw RepositoryError.notImplemented("saveProfile")
    }
}
