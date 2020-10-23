//
//  AIRandomNetworkStrategist.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 10/9/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import GameplayKit

// TODO: Implement the random network distillation strategist.
/// A explorative strategist that uses Random Network Distillation to determine the most optimal move.
///
/// Random Network Distillation (RND) is a reinforcement learning-based strategy that places emphasis on unexplored
/// states, encouraging the strategist to explore the game with rewards for encountering new states. RND scores states
/// by measuring how difficult it is to predict the output based on previous experience.
///
/// For more information, consult the OpenAI article titled
/// [Reinforcement Learning with Prediction-Based Rewards](https://1n.pm/df0Ui).
class AIRandomNetworkStrategist: NSObject, GKStrategist {

    /// A lookup table containing states the strategist has seen before, along with their score.
    var lookupTable = [AIAbstractGameState: Int]()

    /// The game model that the strategist will assess.
    var gameModel: GKGameModel?

    /// The random source for the strategist.
    var randomSource: GKRandom?

    /// Determine the best move for the currently active player.
    func bestMoveForActivePlayer() -> GKGameModelUpdate? {
        guard let model = gameModel as? AIAbstractGameState else { return nil }
        print(model)
        return nil
    }

    /// Train the strategist.
    func train() {

    }

}
