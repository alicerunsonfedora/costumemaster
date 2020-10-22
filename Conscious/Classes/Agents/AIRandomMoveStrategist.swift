//
//  AIRandomMoveStrategist.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 10/16/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import GameplayKit

/// A strategist that will pick random moves.
public class AIRandomMoveStrategist: NSObject, GKStrategist {

    /// The game model that the strategist will use.
    public var gameModel: GKGameModel?

    /// The random source for the strategist.
    public var randomSource: GKRandom?

    /// Returns the best move for the player.
    /// - Returns: A random move.
    public func bestMoveForActivePlayer() -> GKGameModelUpdate? {
        let choice = AIGamePlayerAction.allCases.randomElement() ?? .stop
        return AIGameDecision(by: choice, with: 0)
    }

}
