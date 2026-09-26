//
//  ProfileViewModel.swift
//  IceTime
//
//  Created by Marcel Mravec on 22.09.2026.
//


import Foundation
import Observation

@Observable
final class ProfileViewModel {
    private(set) var profile = Profile()
    private(set) var isBusy = false
    var errorMessage: String?
    
    private let repository: TeamRepository
    
    init(repository: TeamRepository = CloudKitTeamRepository.shared) {
        self.repository = repository
    }
    
    func load() async {
        isBusy = true
        defer { isBusy = false }
        do {
            profile = try await repository.fetchProfile() ?? Profile()
        } catch {
            if !error.isCancellation {
                errorMessage = error.userMessage
            }
        }
    }
    
    func save(_ profile: Profile) async -> Bool {
        guard !isBusy else { return false }
        isBusy = true
        defer { isBusy = false }
        do {
            try await repository.saveProfile(profile)
            self.profile = profile
            return true
        } catch {
            errorMessage = error.userMessage
            return false
        }
    }
}
