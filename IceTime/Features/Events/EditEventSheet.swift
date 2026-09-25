//
//  EditEventSheet.swift
//  IceTime
//
//  Created by Marcel Mravec on 21.09.2026.
//


import SwiftUI

struct EditEventSheet: View {
    let event: Event
    let onSave: (Event) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var date: Date
    @State private var location: String
    @State private var goalieLimit: Int
    @State private var skaterLimit: Int
    
    init(event: Event, onSave: @escaping (Event) -> Void) {
        self.event = event
        self.onSave = onSave
        _date = State(initialValue: event.date)
        _location = State(initialValue: event.location)
        _goalieLimit = State(initialValue: event.goalieLimit)
        _skaterLimit = State(initialValue: event.skaterLimit)
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
            }
            .navigationTitle("Edit Event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(location.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func save() {
        var updated = event
        updated.date = date
        updated.location = location
        updated.goalieLimit = goalieLimit
        updated.skaterLimit = skaterLimit
        onSave(updated)
        dismiss()
    }
}
