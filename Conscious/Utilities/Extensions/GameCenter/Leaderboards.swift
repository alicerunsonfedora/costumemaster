//
//  Leaderboards.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/11/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import GameKit

extension GKLeaderboard {
    /// Submit a score to the following leaderboard.
    ///
    /// This function applies to classic and recurring leaderboards.
    ///
    /// - Parameter leaderboard: The ID of the leaderboard.
    /// - Parameter score: The score to submit to the leaderboard.
    /// - Important: This function is only available on Macs running macOS 11.0.
    @available(OSX 11.0, *) static func submit(to leaderboard: String, with score: Int) {
        if !GKLocalPlayer.local.isAuthenticated
            || !UserDefaults.standard.bool(forKey: "gcSubmitLeaderboardScores") { return }
        GKLeaderboard.submitScore(
            score,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: [leaderboard]
        ) { error in
            guard error == nil else {
                sendAlert(
                    error.debugDescription,
                    withTitle: NSLocalizedString("costumemaster.alert.leaderboard_submit_error_title", comment: "Leaderboard submit error"),
                    level: .critical
                ) { _ in }
                return
            }
        }
    }

    /// Submit a score to the following leaderboard.
    ///
    /// This function applies to classic and recurring leaderboards.
    ///
    /// - Parameter leaderboard: The game leaderboard ID to submit a score to.
    /// - Parameter score: The score to submit to the leaderboard.
    /// - Important: This function is only available on Macs running macOS 11.0.
    @available(OSX 11.0, *) static func submit(to leaderboardID: GameLeaderboard, with score: Int) {
        GKLeaderboard.submit(to: leaderboardID.rawValue, with: score)
    }
}
