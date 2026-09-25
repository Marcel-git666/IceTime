//
//  ErrorAlert.swift
//  IceTime
//
//  Created by Marcel Mravec on 23.09.2026.
//

import SwiftUI

extension View {
    /// Shows an alert while `message` is non-nil and clears it when dismissed.
    func errorAlert(_ message: Binding<String?>) -> some View {
        self.alert("Error", isPresented: Binding(
            get: { message.wrappedValue != nil },
            set: { if !$0 { message.wrappedValue = nil } }
        )) {
        } message: {
            Text(message.wrappedValue ?? "")
        }
    }
}
