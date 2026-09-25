//
//  EventRow.swift
//  IceTime
//
//  Created by Marcel Mravec on 25.09.2026.
//

import SwiftUI

/// One event in the team's event list: date, place, lineup summary and my own answer.
struct EventRow: View {
    let event: Event
    let summary: String
    let myStatus: RSVPStatus?
    let canReply: Bool
    let isEditing: Bool
    let onEdit: () -> Void
    let onReply: (RSVPStatus) -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(event.date, format: .dateTime.day().month().year().hour().minute())
                Text(event.location)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            if isEditing {
                Button(action: onEdit) {
                    EditIndicator()
                }
                .buttonStyle(.borderless)
            } else if canReply {
                RSVPMenu(status: myStatus, onSelect: onReply)
            }
        }
    }
}
