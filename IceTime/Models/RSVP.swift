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
    var respondedAt: Date = .now
}
