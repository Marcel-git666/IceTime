//
//  SceneDelegate.swift
//  IceTime
//
//  Created by Marcel Mravec on 20.09.2026.
//

import CloudKit
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    // Cold launch: the app wasn't running when the invite link was tapped
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        if let metadata = connectionOptions.cloudKitShareMetadata {
            acceptShare(metadata)
        }
    }
    
    // The app was already running
    func windowScene(
        _ windowScene: UIWindowScene,
        userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata
    ) {
        acceptShare(cloudKitShareMetadata)
    }
    
    private func acceptShare(_ metadata: CKShare.Metadata) {
        Task {
            do {
                let container = CKContainer(identifier: metadata.containerIdentifier)
                try await container.accept(metadata)
                NotificationCenter.default.post(name: .teamShareAccepted, object: nil)
            } catch {
                // The scene delegate has no UI of its own, so the teams list shows the alert
                NotificationCenter.default.post(
                    name: .teamShareAcceptFailed,
                    object: "Couldn't join the team. \(error.userMessage)"
                )
            }
        }
    }
}

extension Notification.Name {
    static let teamShareAccepted = Notification.Name("teamShareAccepted")
    /// Posted with the error message as the notification's `object`.
    static let teamShareAcceptFailed = Notification.Name("teamShareAcceptFailed")
}
