//
//  VisibilityChallenge.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 10/15/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SpriteKit
import GameKit

/// The challenge scene associated with "Visibility".
class VisibilityChallenge: ChallengeGameScene {

    /// Grant the "Now You See Me" achievement.
    override func willCalculateChallengeResults() {
        super.willCalculateChallengeResults()
        GKAchievement.earn(with: .visibility)
    }

}
