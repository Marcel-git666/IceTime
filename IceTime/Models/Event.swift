//
//  Event.swift
//  IceTime
//
//  Created by Marcel Mravec on 18.09.2026.
//

import Foundation

struct Event: Identifiable, Codable, Hashable {
    static let defaultGoalieLimit = 2
    static let defaultSkaterLimit = 20
    
    let id: UUID
    var date: Date
    var location: String
    var goalieLimit: Int
    var skaterLimit: Int
    
    init(
        id: UUID = UUID(),
        date: Date,
        location: String,
        goalieLimit: Int = Event.defaultGoalieLimit,
        skaterLimit: Int = Event.defaultSkaterLimit
    ) {
        self.id = id
        self.date = date
        self.location = location
        self.goalieLimit = goalieLimit
        self.skaterLimit = skaterLimit
    }
}

extension Event: Comparable {
    /// Events are always shown in date order.
    static func < (lhs: Event, rhs: Event) -> Bool {
        lhs.date < rhs.date
    }
}
