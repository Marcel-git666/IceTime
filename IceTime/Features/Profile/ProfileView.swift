//
//  ProfileView.swift
//  IceTime
//
//  Created by Marcel Mravec on 22.09.2026.
//


import SwiftUI

struct ProfileView: View {
    /// Optional explanation shown above the form, e.g. why the profile was opened.
    var message: String?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel = ProfileViewModel()
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var isGoalie = false
    @State private var phone = ""
    @State private var email = ""
    
    var body: some View {
        NavigationStack {
            Form {
                if let message {
                    Section {
                        Text(message)
                            .foregroundStyle(.secondary)
                    }
                }
                TextField("First name", text: $firstName)
                TextField("Last name", text: $lastName)
                TextField("Phone", text: $phone)
                TextField("Email", text: $email)
                Toggle("Goalie", isOn: $isGoalie)
            }
            .navigationTitle("My Profile")
            .disabled(viewModel.isBusy)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(viewModel.isBusy)
                }
            }
            .errorAlert($viewModel.errorMessage)
            .task {
                await load()
            }
        }
    }
    
    private func load() async {
        await viewModel.load()
        firstName = viewModel.profile.firstName
        lastName = viewModel.profile.lastName
        isGoalie = viewModel.profile.isGoalie
        phone = viewModel.profile.phone ?? ""
        email = viewModel.profile.email ?? ""
    }
    
    private func save() {
        let profile = Profile(
            firstName: firstName,
            lastName: lastName,
            isGoalie: isGoalie,
            phone: phone.isEmpty ? nil : phone,
            email: email.isEmpty ? nil : email
        )
        Task {
            if await viewModel.save(profile) {
                dismiss()
            }
        }
    }
}
