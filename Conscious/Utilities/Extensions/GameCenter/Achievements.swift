//
//  Achievements.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 8/29/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import GameKit

extension GKAchievement {
    /// Earn an achievment with a given identifier.
    /// - Parameter identifier: The identifier that links to the achievement to earn.
    static func earn(with identifier: String) {
        if !GKLocalPlayer.local.isAuthenticated
            || !UserDefaults.standard.bool(forKey: "gcSubmitAchievements") { return }
        let achievement = GKAchievement(identifier: identifier)
        achievement.percentComplete = 100
        achievement.showsCompletionBanner = UserDefaults.standard.bool(forKey: "gcNotifications")
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

    /// Earn an achievement with a given achievement.
    /// - Parameter achievementName: The game achievement that the player will earn.
    static func earn(with achievementName: GameAchievement) {
        GKAchievement.earn(with: achievementName.rawValue)
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

    /// Update the progress on earning an achievmeent.
    /// - Parameter achievementName: The achievement that the player has progressed on.
    /// - Parameter percent: The percent complete.
    static func updateProgress(on achievementName: GameAchievement, to percent: Double) {
        GKAchievement.updateProgress(on: achievementName.rawValue, to: percent)
    }
}
