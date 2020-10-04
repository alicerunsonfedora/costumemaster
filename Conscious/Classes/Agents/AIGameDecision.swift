//
//  AIGameDecision.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/30/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import GameplayKit

/// An abstract class that represents a decision an agent can make.
class AIGameDecision: NSObject, GKGameModelUpdate {
    
    /// The value of this action.
    var value: Int
    
    /// The action that will be performed.
    var action: AIGamePlayerAction

    /// Instantiate a game decision.
    /// - Parameter action: The action that will be performed in this decision.
    /// - Parameter value: The value of this action.
    init(by action: AIGamePlayerAction, with value: Int) {
        self.value = value
        self.action = action
    }
}
