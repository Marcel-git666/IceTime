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
    private static let key = "teamColors"
    private let store = NSUbiquitousKeyValueStore.default
    private var choices: [String: String] = [:]

    init() {
        store.synchronize()
        choices = store.dictionary(forKey: Self.key) as? [String: String] ?? [:]
    }

    func color(for team: Team) -> TeamColor {
        choices[team.id].flatMap(TeamColor.init(rawValue:)) ?? .defaultColor(for: team)
    }

    func setColor(_ color: TeamColor, for team: Team) {
        choices[team.id] = color.rawValue
        store.set(choices, forKey: Self.key)
    }
}
