//
//  TeamDetailViewModel.swift
//  IceTime
//
//  Created by Marcel Mravec on 20.09.2026.
//


import Foundation
  import CloudKit
  import Observation

  @Observable
  final class TeamDetailViewModel {
      private(set) var isBusy = false
      var errorMessage: String?
      var share: CKShare?

      private let repository: TeamRepository

      init(repository: TeamRepository = CloudKitTeamRepository()) {
          self.repository = repository
      }

      func invite(_ team: Team) async {
          guard !isBusy else { return }
          isBusy = true
          defer { isBusy = false }
          do {
              share = try await repository.shareTeam(team)
          } catch {
              errorMessage = error.localizedDescription
          }
      }
  }
