//
//  RSVPStatus.swift
//  IceTime
//
//  Created by Marcel Mravec on 18.09.2026.
//

import Foundation

enum RSVPStatus: String, Codable, CaseIterable, Hashable {
    case going
    case notGoing
    
    var label: String {
        switch self {
        case .going: "Going"
        case .notGoing: "Not going"
        }
    }
}
