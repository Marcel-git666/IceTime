//
//  PlayerSheet.swift
//  IceTime
//
//  Created by Marcel Mravec on 20.09.2026.
//


import SwiftUI

/// Adds a new guest player, or edits an existing one when `player` is given.
struct PlayerSheet: View {
    let onSave: (String, Bool) -> Void
    private let isEditing: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var isGoalie: Bool

    init(player: Player? = nil, onSave: @escaping (String, Bool) -> Void) {
        _name = State(initialValue: player?.name ?? "")
        _isGoalie = State(initialValue: player?.isGoalie ?? false)
        isEditing = player != nil
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                Toggle("Goalie", isOn: $isGoalie)
            }
            .navigationTitle(isEditing ? "Edit Player" : "Add Player")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add", action: save)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func save() {
        onSave(name, isGoalie)
        dismiss()
    }
}
