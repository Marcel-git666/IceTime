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

extension Player {
    /// A `tel:` link; spaces are removed because the Phone app can't dial them.
    var phoneURL: URL? {
        phone.flatMap { number in
            URL(string: "tel:\(number.filter { !$0.isWhitespace })")
        }
    }
    
    var emailURL: URL? {
        email.flatMap { URL(string: "mailto:\($0)") }
    }
}

extension Player: Comparable {
    /// Rosters are always shown alphabetically, the way Finder and Contacts sort names.
    static func < (lhs: Player, rhs: Player) -> Bool {
        lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
    }
}
