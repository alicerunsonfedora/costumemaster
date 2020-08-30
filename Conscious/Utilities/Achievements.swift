//
//  Achievements.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/29/20.
//

import Foundation
import GameKit

extension GKAchievement {
    /// Earn an achievment with a given identifier.
    /// - Parameter identifier: The identifier that links to the achievement to earn.
    static func earn(with identifier: String) {
        if !GKLocalPlayer.local.isAuthenticated { return }
        let achievement = GKAchievement(identifier: identifier)
        achievement.percentComplete = 100
        GKAchievement.report([achievement]) { error in
            guard error == nil else {
                sendAlert(
                    error.debugDescription,
                    withTitle: "This achievement couldn't be earned.",
                    level: .critical) { _ in }
                return
            }
        }
    }

    /// Update the progress on an achievement.
    static func updateProgress(on identifier: String, to percent: Double) {
        if !GKLocalPlayer.local.isAuthenticated { return }
        let achievement = GKAchievement(identifier: identifier)
        achievement.percentComplete = percent
        GKAchievement.report([achievement]) { error in
            guard error == nil else {
                sendAlert(
                    error.debugDescription,
                    withTitle: "This achievement couldn't be updated.",
                    level: .critical) { _ in }
                return
            }
        }
    }
}
