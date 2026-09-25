//
//  IceTimeApp.swift
//  IceTime
//
//  Created by Marcel Mravec on 18.09.2026.
//

import SwiftUI

@main
struct IceTimeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            TeamsListView()
        }
    }
}
