//
//  AddEventSheet.swift
//  IceTime
//
//  Created by Marcel Mravec on 21.09.2026.
//


import SwiftUI

struct AddEventSheet: View {
    let onAdd: (Event, Recurrence) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var date = Date.now
    @State private var location = ""
    @State private var goalieLimit = Event.defaultGoalieLimit
    @State private var skaterLimit = Event.defaultSkaterLimit
    @State private var frequency: RecurrenceFrequency = .none
    @State private var endChoice: EndChoice = .occurrenceCount
    @State private var occurrenceCount = 4
    @State private var endDate = Calendar.current.date(byAdding: .month, value: 1, to: .now) ?? .now
    
    enum EndChoice: Hashable {
        case occurrenceCount
        case endDate
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Date", selection: $date)
                    TextField("Location", text: $location)
                }
                
                Section("Lineup") {
                    Stepper("Goalies: \(goalieLimit)", value: $goalieLimit, in: 1...4)
                    Stepper("Skaters: \(skaterLimit)", value: $skaterLimit, in: 1...40)
                }
                
                Section("Repeat") {
                    Picker("Frequency", selection: $frequency) {
                        Text("Never").tag(RecurrenceFrequency.none)
                        Text("Daily").tag(RecurrenceFrequency.daily)
                        Text("Weekly").tag(RecurrenceFrequency.weekly)
                    }
                    
                    if frequency != .none {
                        Picker("Ends", selection: $endChoice) {
                            Text("After").tag(EndChoice.occurrenceCount)
                            Text("On date").tag(EndChoice.endDate)
                        }
                        .pickerStyle(.segmented)
                        
                        if endChoice == .occurrenceCount {
                            Stepper("\(occurrenceCount) times", value: $occurrenceCount, in: 2...Recurrence.maxOccurrences)
                        } else {
                            DatePicker("End date", selection: $endDate, in: date..., displayedComponents: .date)
                        }
                    }
                }
            }
            .navigationTitle("Add Event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", action: add)
                        .disabled(location.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func add() {
        let end: Recurrence.End = endChoice == .occurrenceCount
            ? .occurrenceCount(occurrenceCount)
            : .endDate(endDate)
        let template = Event(date: date, location: location, goalieLimit: goalieLimit, skaterLimit: skaterLimit)
        onAdd(template, Recurrence(frequency: frequency, end: end))
        dismiss()
    }
}
