//
//  AIGameStrategy.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/2/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import GameplayKit

/// A base strategy class.
@available(OSX 10.15, *)
class AIGameStrategy: NSObject, GKStrategist {

    /// The console that the strategy will send messages to.
    var console: ConsoleViewModel?

    /// The game model that will be used in the particular strategy.
    var gameModel: GKGameModel?

    /// The random source that the strategy can use.
    var randomSource: GKRandom?

    /// Returns the best move for the active player.
    func bestMoveForActivePlayer() -> GKGameModelUpdate? {
        console?.warn("bestMoveForActivePlayer has not been implemented for this agent.")
        return nil
    }
}
