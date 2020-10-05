//
//  CycleChallenge.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/14/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SpriteKit
import GameKit

/// The game scene specific to the level "Cycle".
class CycleChallenge: ChallengeGameScene {

    /// Submit the current time to the dailly leaderboards if running on macOS Big Sur.
    override func willCalculateChallengeResults() {
        if #available(OSX 11.0, *) {
            GKLeaderboard.submit(to: .cycleDaily, with: Int(self.currentTime))
        }
        self.announceTimeResults()
    }

}
