//
//  AIRandomWeightedStrategist.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 10/23/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import GameplayKit

/// A strategist that will pick a random move from a random list of actions with the highest weight.
class AIRandomWeightedStrategist: AIGameStrategy {

    /// Returns the best move for the player.
    /// - Returns: A random move with the highest weight.
    override func bestMoveForActivePlayer() -> GKGameModelUpdate? {
        var actions = [AIGameDecision]()
        for action in AIGamePlayerAction.allCases {
            actions.append(AIGameDecision(by: action, with: randomSource?.nextInt() ?? 0))
        }
        return actions.max { first, second in first.value > second.value }
    }

}
