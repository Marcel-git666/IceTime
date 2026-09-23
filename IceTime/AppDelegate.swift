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
    // Cold launch: the app wasn't running when the invite link was tapped
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        print("📥 willConnectTo")
        if let metadata = connectionOptions.cloudKitShareMetadata {
            acceptShare(metadata)
        }
    }
    
    // The app was already running
    func windowScene(
        _ windowScene: UIWindowScene,
        userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata
    ) {
        print("📥 userDidAccept")
        acceptShare(cloudKitShareMetadata)
    }
    
    private func acceptShare(_ metadata: CKShare.Metadata) {
        Task {
            do {
                let container = CKContainer(identifier: metadata.containerIdentifier)
                try await container.accept(metadata)
                NotificationCenter.default.post(name: .teamShareAccepted, object: nil)
            } catch {
                print("❌ Failed to accept share: \(error)")
            }
        }
    }
}

extension Notification.Name {
    static let teamShareAccepted = Notification.Name("teamShareAccepted")
}
