//
//  EventsSection.swift
//  IceTime
//
//  Created by Marcel Mravec on 25.09.2026.
//

import SwiftUI

/// The team's events with a lineup summary, quick replies, and owner-only edit and delete.
struct EventsSection: View {
    let team: Team
    let isEditing: Bool
    let eventsViewModel: EventsViewModel
    let rosterViewModel: RosterViewModel
    @Binding var editingEvent: Event?

    private var isOwner: Bool {
        team.role == .owner
    }

    var body: some View {
        Section {
            ForEach(eventsViewModel.events) { event in
                NavigationLink(value: event) {
                    EventRow(
                        event: event,
                        summary: lineupSummary(for: event),
                        myStatus: myStatus(for: event),
                        canReply: rosterViewModel.currentPlayer != nil,
                        isEditing: isEditing && isOwner,
                        onEdit: { editingEvent = event },
                        onReply: { status in reply(status, to: event) }
                    )
                }
                .swipeActions {
                    if isOwner {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            delete(event)
                        }
                        Button("Edit", systemImage: "pencil") {
                            editingEvent = event
                        }
                        .tint(.blue)
                    }
                }
                .deleteDisabled(!isOwner)
            }
            .onDelete(perform: deleteEvents)
        }
    }

    private func lineupSummary(for event: Event) -> String {
        let lineup = eventsViewModel.lineup(for: event, roster: rosterViewModel.players)
        let goalies = "Goalies \(lineup.goalies.count)/\(event.goalieLimit)"
        let skaters = "Skaters \(lineup.skaters.count)/\(event.skaterLimit)"
        var summary = "\(goalies) · \(skaters)"
        let subs = lineup.goalieSubs.count + lineup.skaterSubs.count
        if subs > 0 {
            summary += " · \(subs) subs"
        }
        return summary
    }

    private func myStatus(for event: Event) -> RSVPStatus? {
        guard let me = rosterViewModel.currentPlayer else { return nil }
        return eventsViewModel.rsvp(of: me, for: event)?.status
    }

    private func reply(_ status: RSVPStatus, to event: Event) {
        guard let me = rosterViewModel.currentPlayer else { return }
        Task { await eventsViewModel.setRSVP(status, for: me, event: event, in: team) }
    }

    private func delete(_ event: Event) {
        Task { await eventsViewModel.deleteEvent(event, from: team) }
    }

    private func deleteEvents(at offsets: IndexSet) {
        // Turn indexes into events right away: the array may change while deleting
        let events = offsets.map { eventsViewModel.events[$0] }
        Task {
            for event in events {
                await eventsViewModel.deleteEvent(event, from: team)
            }
        }
    }
}
