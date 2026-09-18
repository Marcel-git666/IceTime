//
//  Event.swift
//  IceTime
//
//  Created by Marcel Mravec on 18.09.2026.
//

import Foundation

struct Event: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var location: String
    
    init(id: UUID = UUID(), date: Date, location: String) {
        self.id = id
        self.date = date
        self.location = location
    }
}
