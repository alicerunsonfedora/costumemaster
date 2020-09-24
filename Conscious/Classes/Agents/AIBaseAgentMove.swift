//
//  AIBaseAgentMove.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/24/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import GameplayKit

/// A class representation of a move the agent can make.
class AIBaseAgentMove: NSObject, GKGameModelUpdate {

    /// The value of this move (i.e., how valuable of a move this is to an agent).
    var value: Int = 0

    /// The action the agent will perform in this move.
    var action: AIBaseAgentMoveAction

    /// Initialize a game move for an agent to make.
    /// - Parameter action: The action the agent will perform.
    init(with action: AIBaseAgentMoveAction) {
        self.action = action
    }

}
