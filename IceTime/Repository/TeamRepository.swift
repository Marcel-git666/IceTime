//
//  TeamRepository.swift
//  IceTime
//
//  Created by Marcel Mravec on 18.09.2026.
//


import Foundation
import CloudKit

protocol TeamRepository {
    
    // MARK: Teams
    
    func fetchTeams() async throws -> [Team]
    
    func createTeam(name: String) async throws -> Team
    
    func shareTeam(_ team: Team) async throws -> CKShare
    
    func currentUserRecordID() async throws -> String
    
    // MARK: Profile
    
    func fetchProfile() async throws -> Profile?
    func saveProfile(_ profile: Profile) async throws
    
    // MARK: Roster
    
    func fetchRoster(for team: Team) async throws -> [Player]
    func addPlayerToRoster(_ player: Player, to team: Team) async throws
    
    // MARK: Events
    
    func createEvent(_ event: Event, in team: Team) async throws
    func fetchEvents(for team: Team) async throws -> [Event]
    func updateEvent(_ event: Event, in team: Team) async throws
    
    // MARK: RSVPs
    
    func submitRSVP(_ rsvp: RSVP, in team: Team) async throws
    func fetchRSVPs(for eventID: UUID, in team: Team) async throws -> [RSVP]
    
    // MARK: Deletion
    
    func deleteEvent(_ event: Event, in team: Team) async throws
    
    func deleteTeam(_ team: Team) async throws
}

enum RepositoryError: LocalizedError {
    case iCloudUnavailable
    case malformedRecord(String)
    case teamNotFound
    case notImplemented(String)
    case notOwner
    
    var errorDescription: String? {
        switch self {
        case .iCloudUnavailable:
            return "Sign into iCloud in Settings to use IceTime."
        case .malformedRecord(let detail):
            return "Unexpected data from server: \(detail)"
        case .teamNotFound:
            return "This team could not be found."
        case .notImplemented(let feature):
            return "\(feature) is not implemented yet."
        case .notOwner:
            return "Only the team owner can do this."
        }
    }
}
