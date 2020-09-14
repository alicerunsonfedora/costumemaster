//
//  RushedChallenge.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/12/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SpriteKit
import GameKit

/// The game scene specific to the level "Rushed."
class RushedChallenge: ChallengeGameScene {

    /// Submit the leaderboard scores for the daily fastest.
    override func willCalculateChallengeResults() {
        super.willCalculateChallengeResults()
        if #available(OSX 11.0, *) {
            GKLeaderboard.submit(to: .rushedDaily, with: Int(self.currentTime))
        }
    }

}
