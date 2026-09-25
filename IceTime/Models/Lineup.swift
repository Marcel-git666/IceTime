//
//  Lineup.swift
//  IceTime
//
//  Created by Marcel Mravec on 24.09.2026.
//

import Foundation

struct Lineup {
    var goalies: [Player] = []
    var skaters: [Player] = []
    var goalieSubs: [Player] = []
    var skaterSubs: [Player] = []
    var notGoing: [Player] = []
    var undecided: [Player] = []
}

extension Lineup {
    /// Going players get a spot first come, first served, up to the event's limits;
    /// everyone over the limit is a substitute.
    init(event: Event, roster: [Player], rsvps: [RSVP]) {
        var going: [(player: Player, respondedAt: Date)] = []
        
        for player in roster {
            guard let rsvp = rsvps.first(where: { $0.eventID == event.id && $0.playerID == player.id }) else {
                undecided.append(player)
                continue
            }
            switch rsvp.status {
            case .going: going.append((player, rsvp.respondedAt))
            case .notGoing: notGoing.append(player)
            }
        }
        
        let queue = going.sorted { $0.respondedAt < $1.respondedAt }.map(\.player)
        let goalieQueue = queue.filter(\.isGoalie)
        let skaterQueue = queue.filter { !$0.isGoalie }
        
        goalies = Array(goalieQueue.prefix(event.goalieLimit))
        goalieSubs = Array(goalieQueue.dropFirst(event.goalieLimit))
        skaters = Array(skaterQueue.prefix(event.skaterLimit))
        skaterSubs = Array(skaterQueue.dropFirst(event.skaterLimit))
    }
}
