//
//  AIReflexStrategist.swift
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

/// A subclassed random move agent that changes actions based on reflexes.
@available(OSX 10.15, *)
class AIReflexStrategist: AIRandomMoveStrategist {

    /// Returns the best move for the active player.
    override func bestMoveForActivePlayer() -> GKGameModelUpdate? {
        console?.warn("Returning a random move because no reflexes were detected.")
        return super.bestMoveForActivePlayer()
    }

}
