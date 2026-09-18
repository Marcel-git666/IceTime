//
//  RSVP.swift
//  IceTime
//
//  Created by Marcel Mravec on 18.09.2026.
//

import Foundation

struct RSVP: Identifiable, Codable, Hashable {
    let id: UUID
    var playerID: UUID
    var eventID: UUID
    var status: RSVPStatus
    var timestamp: Date
    
    init(id: UUID = UUID(), playerID: UUID, eventID: UUID, status: RSVPStatus, timestamp: Date = .now) {
        self.id = id
        self.playerID = playerID
        self.eventID = eventID
        self.status = status
        self.timestamp = timestamp
    }
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
