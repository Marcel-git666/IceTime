//
//  AddPlayerSheet.swift
//  IceTime
//
//  Created by Marcel Mravec on 20.09.2026.
//


import SwiftUI

struct AddPlayerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var isGoalie = false
    let onAdd: (String, Bool) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                Toggle("Goalie", isOn: $isGoalie)
            }
            .navigationTitle("Add Player")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd(name, isGoalie)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
