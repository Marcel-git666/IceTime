//
//  Team.swift
//  IceTime
//
//  Created by Marcel Mravec on 18.09.2026.
//

import Foundation

// id is name of CloudKit zone
struct Team: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var role: TeamRole
}
