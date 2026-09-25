//
//  Recurrence.swift
//  IceTime
//
//  Created by Marcel Mravec on 21.09.2026.
//

import Foundation

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
