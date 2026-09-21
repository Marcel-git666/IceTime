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
            while let next = calendar.date(byAdding: component, value: 1, to: current), next <= endDate {
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
            events = try await repository.fetchEvents(for: team)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func createEvents(startDate: Date, location: String, recurrence: Recurrence, to team: Team) async {
        guard !isBusy else { return }
        isBusy = true
        defer { isBusy = false }
        do {
            for date in recurrence.occurrenceDates(startingAt: startDate) {
                let event = Event(date: date, location: location)
                try await repository.createEvent(event, in: team)
                events.append(event)
            }
            events.sort { $0.date < $1.date }
        } catch {
            errorMessage = error.localizedDescription
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
            errorMessage = error.localizedDescription
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
            errorMessage = error.localizedDescription
        }
    }
}
