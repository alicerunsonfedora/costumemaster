//
//  CostumemasteryInheritable.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/14/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import GameKit
import SpriteKit

/// A challenge game scene that listens for whether the player has earned the Costumemastery achievement.
class CostumemasteryInheritable: ChallengeGameScene {
    /// Determine if the player is eligible to receive the Costumemastery achievement and grant it.
    /// - Important: For subclasses that will override this method, make sure to call the parent to make this
    /// achievement accessible in the challenge.
    override func willCalculateChallengeResults() {
        super.willCalculateChallengeResults()

        if totalCostumeIncrement <= 10 {
            GKAchievement.earn(with: .costumemastery)
        }
    }
}
