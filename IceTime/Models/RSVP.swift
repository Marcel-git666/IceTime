//
//  RSVP.swift
//  IceTime
//
//  Created by Marcel Mravec on 18.09.2026.
//

import Foundation

struct RSVP: Codable, Hashable {
    let playerID: UUID
    let eventID: UUID
    var status: RSVPStatus
}

enum RSVPStatus: String, Codable, CaseIterable, Hashable {
    case going
    case notGoing
    case maybe
    
    var label: String {
        switch self {
        case .going: return "Going"
        case .notGoing: return "Not going"
        case .maybe: return "Maybe"
        }
    }
}
