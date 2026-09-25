//
//  TeamSection.swift
//  IceTime
//
//  Created by Marcel Mravec on 25.09.2026.
//

import Foundation

/// The two parts of a team screen, switched with a segmented picker.
enum TeamSection: String, CaseIterable, Identifiable {
    case events = "Events"
    case roster = "Roster"

    var id: Self { self }
}
