//
//  ExposureChallenge.swift
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

/// The game scene corresponding to the level "Exposure".
class ExposureChallenge: CostumemasteryInheritable {

    /// Submit the score to the daily leaderboards.
    override func willCalculateChallengeResults() {
        super.willCalculateChallengeResults()
        if #available(OSX 11.0, *) {
            GKLeaderboard.submit(to: .exposureDaily, with: Int(self.currentTime))
        }
        self.announceTimeResults()
    }

}
