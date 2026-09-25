//
//  RSVPStatusIcon.swift
//  IceTime
//
//  Created by Marcel Mravec on 25.09.2026.
//

import SwiftUI

/// Colored icon for an RSVP answer; nil means the player hasn't answered yet.
struct RSVPStatusIcon: View {
    let status: RSVPStatus?

    var body: some View {
        Image(systemName: symbol)
            .font(.title2)
            .foregroundStyle(color)
            .accessibilityLabel(status?.label ?? "No answer")
    }

    private var symbol: String {
        switch status {
        case .going: "checkmark.circle.fill"
        case .notGoing: "xmark.circle.fill"
        case nil: "questionmark.circle"
        }
    }

    private var color: Color {
        switch status {
        case .going: .green
        case .notGoing: .red
        case nil: .gray
        }
    }
}
