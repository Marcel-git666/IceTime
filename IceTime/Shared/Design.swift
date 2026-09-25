//
//  Design.swift
//  IceTime
//
//  Created by Marcel Mravec on 26.09.2026.
//

import Foundation

/// Visual values shared across screens, so the app looks consistent and can be tuned in one place.
enum Design {
    /// Rounded corners of team cards.
    static let cardCornerRadius = 16.0
    /// Gap between team cards in the list.
    static let cardSpacing = 12.0
    /// How strong the team color is behind team and event screens.
    static let teamBackgroundOpacity = 0.15
    /// Highlight of the current user's own row in the roster.
    static let currentUserHighlightOpacity = 0.3
}
