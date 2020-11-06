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
class AIHistoryTreeStrategist: AITreeStrategy {

    var tree: GKDecisionTree?

    /// Initialize the history tree strategist.
    override init() {
        super.init()
        self.recordsHistory = true
    }

    /// Returns the default action when other actions could not be supplied.
    override func defaultAction() -> AIGameDecision {
        return AIGameDecision(by: AIGamePlayerAction(rawValue: moveRandom()) ?? .stop, with: -100)
    }

    /// Create the decision tree that the agent will use to assess the states.
    override func makeDecisionTree() -> GKDecisionTree {
        if self.history.count < 20 {
            console?.error("Agent history at: \(self.history.count). Using a random action tree instead.")
            return randomDummyTree()
        }

        let tests = self.history.map { entry in entry.assessement.toList() }
        let moves = self.history.map { entry in entry.derivedAction }
        let questions = [
            "canEscape?", "nearExit?", "nearInput?", "inputActive?", "inputRelevant?", "requiresObject?",
            "requiresCostume?", "hasObject?", "nearObj?", "allInputsActive?"
        ]

        //swiftlint:disable force_cast
        DispatchQueue.main.async {
            self.console?.warn("Generating a tree from episodes. This may take a while.")
            self.tree = GKDecisionTree(
                examples: tests as NSArray as! [[NSObjectProtocol]],
                actions: moves as NSArray as! [NSObjectProtocol],
                attributes: questions as NSArray as! [NSObjectProtocol]
            )
            print(self.tree?.description)
        }
        //swiftlint:enable force_cast
        return randomDummyTree()
    }

    /// Returns a tree with a random move at its branches.
    func randomDummyTree() -> GKDecisionTree {
        let tree = GKDecisionTree(attribute: "canEscape?".toProtocol())
        tree.rootNode?.createBranch(value: true, attribute: "MOVE_RANDOM".toProtocol())
        tree.rootNode?.createBranch(value: false, attribute: "MOVE_RANDOM".toProtocol())
        return tree
    }

}
