//
//  EventsViewModel.swift
//  IceTime
//
//  Created by Marcel Mravec on 21.09.2026.
//


import Foundation
import Observation

enum RecurrenceFrequency: Hashable {
    case none
    case daily
    case weekly
}

struct Recurrence {
    var frequency: RecurrenceFrequency
    var end: End
    
    static let maxOccurrences = 52
    
    enum End {
        case occurrenceCount(Int)
        case endDate(Date)
    }
    
    func occurrenceDates(startingAt startDate: Date) -> [Date] {
        guard frequency != .none else { return [startDate] }
        let calendar = Calendar.current
        let component: Calendar.Component = frequency == .daily ? .day : .weekOfYear
        
        var dates: [Date] = [startDate]
        var current = startDate
        
        switch end {
        case .occurrenceCount(let count):
            while dates.count < count, let next = calendar.date(byAdding: component, value: 1, to: current) {
                dates.append(next)
                current = next
            }
        case .endDate(let endDate):
            // The picker selects a day; include every occurrence on that day
            let startOfEndDay = calendar.startOfDay(for: endDate)
            guard let dayAfterEnd = calendar.date(byAdding: .day, value: 1, to: startOfEndDay) else { break }
            while dates.count < Self.maxOccurrences, let next = calendar.date(byAdding: component, value: 1, to: current), next < dayAfterEnd {
                dates.append(next)
                current = next
            }
        }
        return dates
    }
}

@Observable
final class EventsViewModel {
    private(set) var events: [Event] = []
    private var rsvps: [RSVP] = []
    private(set) var isBusy = false
    var errorMessage: String?
    
    private let repository: TeamRepository
    
    init(repository: TeamRepository = CloudKitTeamRepository()) {
        self.repository = repository
    }
    
    func load(for team: Team) async {
        isBusy = true
        defer { isBusy = false }
        do {
            async let fetchedEvents = repository.fetchEvents(for: team)
            async let fetchedRSVPs = repository.fetchRSVPs(for: team)
            events = try await fetchedEvents
            rsvps = try await fetchedRSVPs
        } catch {
            errorMessage = error.userMessage
        }
    }
    
    func createEvents(from template: Event, recurrence: Recurrence, to team: Team) async {
        guard !isBusy else { return }
        isBusy = true
        defer { isBusy = false }
        do {
            let newEvents = recurrence.occurrenceDates(startingAt: template.date).map { date in
                Event(
                    date: date,
                    location: template.location,
                    goalieLimit: template.goalieLimit,
                    skaterLimit: template.skaterLimit
                )
            }
            try await repository.createEvents(newEvents, in: team)
            events.append(contentsOf: newEvents)
            events.sort { $0.date < $1.date }
        } catch {
            errorMessage = error.userMessage
        }
    }
    
    func deleteEvent(_ event: Event, from team: Team) async {
        guard !isBusy else { return }
        isBusy = true
        defer { isBusy = false }
        do {
            try await repository.deleteEvent(event, in: team)
            events.removeAll { $0.id == event.id }
        } catch {
            errorMessage = error.userMessage
        }
    }
    
    func updateEvent(_ event: Event, in team: Team) async {
        guard !isBusy else { return }
        isBusy = true
        defer { isBusy = false }
        do {
            try await repository.updateEvent(event, in: team)
            if let index = events.firstIndex(where: { $0.id == event.id }) {
                events[index] = event
            }
            events.sort { $0.date < $1.date }
        } catch {
            errorMessage = error.userMessage
        }
    }
    
    func rsvp(of player: Player, for event: Event) -> RSVP? {
        rsvps.first { $0.eventID == event.id && $0.playerID == player.id }
    }
    
    func setRSVP(_ status: RSVPStatus, for player: Player, event: Event, in team: Team) async {
        // Re-sending the same answer would bump modificationDate and move the player to the back of the queue
        guard rsvp(of: player, for: event)?.status != status else { return }
        
        let previous = rsvps
        let rsvp = RSVP(playerID: player.id, eventID: event.id, status: status)
        rsvps.removeAll { $0.eventID == event.id && $0.playerID == player.id }
        rsvps.append(rsvp)
        do {
            try await repository.submitRSVP(rsvp, in: team)
        } catch {
            rsvps = previous
            errorMessage = error.userMessage
        }
    }
    
    func lineup(for event: Event, roster: [Player]) -> Lineup {
        Lineup(event: event, roster: roster, rsvps: rsvps)
    }
}
