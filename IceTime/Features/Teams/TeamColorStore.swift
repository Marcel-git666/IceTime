//
//  TeamColorStore.swift
//  IceTime
//
//  Created by Marcel Mravec on 25.09.2026.
//


import Foundation
import Observation

/// Remembers each player's team colors in iCloud key-value storage: it works like UserDefaults,
/// but syncs across the player's own devices, and stays out of the shared team data.
@Observable
final class TeamColorStore {
    private static let keyPrefix = "teamColor."
    private let store = NSUbiquitousKeyValueStore.default
    /// Colors picked while the app runs, so views update right away.
    private var choices: [String: TeamColor] = [:]
    
    init() {
        store.synchronize()
    }
    
    func color(for team: Team) -> TeamColor {
        if let choice = choices[team.id] {
            return choice
        }
        let saved = store.string(forKey: key(for: team)).flatMap(TeamColor.init(rawValue:))
        return saved ?? .defaultColor(for: team)
    }
    
    func setColor(_ color: TeamColor, for team: Team) {
        choices[team.id] = color
        store.set(color.rawValue, forKey: key(for: team))
    }
    
    private func key(for team: Team) -> String {
        Self.keyPrefix + team.id
    }
}
