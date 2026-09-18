//
//  Player.swift
//  IceTime
//
//  Created by Marcel Mravec on 18.09.2026.
//

import Foundation

// Player.userRecordID: String? — nil means guest added by someone else (Android user :) )
struct Player: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var isGoalie: Bool
    var userRecordID: String?
    var photo: Data?
    var phone: String?
    var email: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        isGoalie: Bool = false,
        userRecordID: String? = nil,
        photo: Data? = nil,
        phone: String? = nil,
        email: String? = nil
    ) {
        self.id = id
        self.name = name
        self.isGoalie = isGoalie
        self.userRecordID = userRecordID
        self.photo = photo
        self.phone = phone
        self.email = email
    }
}
