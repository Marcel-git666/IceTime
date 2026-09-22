//
//  Profile.swift
//  IceTime
//
//  Created by Marcel Mravec on 18.09.2026.
//

import Foundation

struct Profile: Codable, Hashable {
    var firstName: String
    var lastName: String
    var isGoalie: Bool
    var photo: Data?
    var phone: String?
    var email: String?
    
    var displayName: String {
        [firstName, lastName]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
    
    init(firstName: String = "", lastName: String = "", isGoalie: Bool = false, photo: Data? = nil, phone: String? = nil, email:
         String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.isGoalie = isGoalie
        self.photo = photo
        self.phone = phone
        self.email = email
    }
}
