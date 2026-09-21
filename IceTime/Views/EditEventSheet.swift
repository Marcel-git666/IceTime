//
//  EditEventSheet.swift
//  IceTime
//
//  Created by Marcel Mravec on 21.09.2026.
//


import SwiftUI

struct EditEventSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var date: Date
    @State private var location: String
    let event: Event
    let onSave: (Event) -> Void
    
    init(event: Event, onSave: @escaping (Event) -> Void) {
        self.event = event
        self.onSave = onSave
        _date = State(initialValue: event.date)
        _location = State(initialValue: event.location)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $date)
                TextField("Location", text: $location)
            }
            .navigationTitle("Edit Event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updated = event
                        updated.date = date
                        updated.location = location
                        onSave(updated)
                        dismiss()
                    }
                    .disabled(location.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
