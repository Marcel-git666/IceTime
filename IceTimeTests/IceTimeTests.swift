//
//  IceTimeTests.swift
//  IceTimeTests
//
//  Created by Marcel Mravec on 25.09.2026.
//

import Foundation
import Testing
@testable import IceTime

@MainActor
struct LineupTests {
    let event = Event(date: .now, location: "Rink", goalieLimit: 2, skaterLimit: 2)
    
    private func rsvp(_ player: Player, _ status: RSVPStatus, minutesAgo: Double) -> RSVP {
        RSVP(
            playerID: player.id,
            eventID: event.id,
            status: status,
            respondedAt: Date(timeIntervalSinceNow: -minutesAgo * 60)
        )
    }
    
    @Test func goalieOverTheLimitBecomesSubstitute() {
        let first = Player(name: "First", isGoalie: true)
        let second = Player(name: "Second", isGoalie: true)
        let third = Player(name: "Third", isGoalie: true)
        
        let lineup = Lineup(event: event, roster: [first, second, third], rsvps: [
            rsvp(first, .going, minutesAgo: 30),
            rsvp(second, .going, minutesAgo: 20),
            rsvp(third, .going, minutesAgo: 10),
        ])
        
        #expect(lineup.goalies == [first, second])
        #expect(lineup.goalieSubs == [third])
    }
    
    @Test func spotsGoByResponseTimeNotRosterOrder() {
        let early = Player(name: "Early")
        let middle = Player(name: "Middle")
        let late = Player(name: "Late")
        
        let lineup = Lineup(event: event, roster: [late, middle, early], rsvps: [
            rsvp(late, .going, minutesAgo: 1),
            rsvp(middle, .going, minutesAgo: 5),
            rsvp(early, .going, minutesAgo: 10),
        ])
        
        #expect(lineup.skaters == [early, middle])
        #expect(lineup.skaterSubs == [late])
    }
    
    @Test func substituteMovesUpWhenPlayerDropsOut() {
        let a = Player(name: "A")
        let b = Player(name: "B")
        let c = Player(name: "C")
        
        let lineup = Lineup(event: event, roster: [a, b, c], rsvps: [
            rsvp(a, .going, minutesAgo: 30),
            rsvp(b, .notGoing, minutesAgo: 1),   // was going, then dropped out
            rsvp(c, .going, minutesAgo: 10),
        ])
        
        #expect(lineup.skaters == [a, c])
        #expect(lineup.skaterSubs.isEmpty)
        #expect(lineup.notGoing == [b])
    }
    
    @Test func playersWithoutAnswerAreUndecided() {
        let answered = Player(name: "Answered")
        let silent = Player(name: "Silent")
        
        let lineup = Lineup(event: event, roster: [answered, silent], rsvps: [
            rsvp(answered, .going, minutesAgo: 5),
        ])
        
        #expect(lineup.undecided == [silent])
    }
    
    @Test func rsvpOfPlayerNotOnRosterIsIgnored() {
        let onRoster = Player(name: "On roster")
        let removed = Player(name: "Removed")
        
        let lineup = Lineup(event: event, roster: [onRoster], rsvps: [
            rsvp(onRoster, .going, minutesAgo: 5),
            rsvp(removed, .going, minutesAgo: 10),
        ])
        
        #expect(lineup.skaters == [onRoster])
    }
}

@MainActor
struct RecurrenceTests {
    let calendar = Calendar.current
    
    @Test func endDateIncludesOccurrenceOnTheLastDay() throws {
        // Tuesday 19:00; the end date is picked at 10:00 on the last Tuesday
        let start = try #require(calendar.date(from: DateComponents(year: 2026, month: 10, day: 6, hour: 19)))
        let end = try #require(calendar.date(from: DateComponents(year: 2026, month: 10, day: 27, hour: 10)))
        
        let dates = Recurrence(frequency: .weekly, end: .endDate(end)).occurrenceDates(startingAt: start)
        
        #expect(dates.count == 4)
        // Crosses the switch to winter time on Oct 25; practice stays at 19:00
        #expect(dates.allSatisfy { calendar.component(.hour, from: $0) == 19 })
    }
    
    @Test func longSeriesIsCapped() throws {
        let start = try #require(calendar.date(from: DateComponents(year: 2026, month: 10, day: 1, hour: 19)))
        let end = try #require(calendar.date(byAdding: .year, value: 2, to: start))
        
        let dates = Recurrence(frequency: .daily, end: .endDate(end)).occurrenceDates(startingAt: start)
        
        #expect(dates.count == Recurrence.maxOccurrences)
    }
    
    @Test func occurrenceCountIsRespected() {
        let dates = Recurrence(frequency: .weekly, end: .occurrenceCount(4)).occurrenceDates(startingAt: .now)
        #expect(dates.count == 4)
    }
}
