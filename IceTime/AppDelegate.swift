//
//  AppDelegate.swift
//  IceTime
//
//  Created by Marcel Mravec on 20.09.2026.
//


import CloudKit
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func windowScene(
        _ windowScene: UIWindowScene,
        userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata
    ) {
        Task {
            do {
                let container = CKContainer(identifier: CloudKitTeamRepository.containerID)
                try await container.accept(cloudKitShareMetadata)
                print("✅ Share accepted")
            } catch {
                print("❌ Failed to accept share: \(error)")
            }
        }
    }
}
