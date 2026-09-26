//
//  Error+UserMessage.swift
//  IceTime
//
//  Created by Marcel Mravec on 23.09.2026.
//

import CloudKit

extension Error {
    /// True when the work was cancelled on purpose, e.g. the user left the screen mid-load.
    var isCancellation: Bool {
        if self is CancellationError { return true }
        return (self as? CKError)?.code == .operationCancelled
    }
    
    /// A message suitable for showing to the user.
    var userMessage: String {
        guard let ckError = self as? CKError else {
            return localizedDescription
        }
        switch ckError.code {
        case .networkUnavailable, .networkFailure:
            return "You're offline. Check your internet connection and try again."
        case .notAuthenticated:
            return "Sign into iCloud in Settings to use IceTime."
        case .serviceUnavailable, .requestRateLimited, .zoneBusy:
            return "iCloud is busy right now. Please try again in a moment."
        case .quotaExceeded:
            return "Your iCloud storage is full."
        case .permissionFailure:
            return "You don't have permission to make this change."
        default:
            return localizedDescription
        }
    }
}
