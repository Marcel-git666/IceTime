//
//  RSVPMenu.swift
//  IceTime
//
//  Created by Marcel Mravec on 25.09.2026.
//


import SwiftUI

/// Tappable RSVP icon that lets the user pick an answer.
struct RSVPMenu: View {
    let status: RSVPStatus?
    let onSelect: (RSVPStatus) -> Void

    var body: some View {
        Menu {
            ForEach(RSVPStatus.allCases, id: \.self) { option in
                Button(option.label) { onSelect(option) }
            }
        } label: {
            RSVPStatusIcon(status: status)
        }
    }
}
