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

      init(repository: TeamRepository = CloudKitTeamRepository()) {
          self.repository = repository
      }

      func load() async {
          isBusy = true
          defer { isBusy = false }
          do {
              profile = try await repository.fetchProfile() ?? Profile()
          } catch {
              errorMessage = error.localizedDescription
          }
      }

      func save(_ profile: Profile) async {
          guard !isBusy else { return }
          isBusy = true
          defer { isBusy = false }
          do {
              try await repository.saveProfile(profile)
              self.profile = profile
          } catch {
              errorMessage = error.localizedDescription
          }
      }
  }