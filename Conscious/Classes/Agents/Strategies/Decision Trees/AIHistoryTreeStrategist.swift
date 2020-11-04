//
//  AIHistoryTreeStrategist.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/4/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import GameplayKit

/// A decision tree-based strategy that uses previous attempts to create the decision tree.
@available(OSX 10.15, *)
class AIHistoryTreeStrategist: AITreeStrategy {

    /// Initialize the history tree strategist.
    override init() {
        super.init()
        self.recordsHistory = true
    }

    /// Create the decision tree that the agent will use to assess the states.
    override func makeDecisionTree() -> GKDecisionTree {
        let history = self.history.map { item in item.assessement.toExample() }
        return GKDecisionTree(examples: history, actions: actions, attributes: attrribs)
    }

}
