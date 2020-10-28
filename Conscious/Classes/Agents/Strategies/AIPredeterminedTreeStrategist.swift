//
//  AIPredeterminedTreeStrategist.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 10/26/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import GameplayKit

/// A strategist that will pick the best move based on a predetermined GKDecision tree.
class AIPredeterminedTreeStrategist: NSObject, GKStrategist {

    /// The game model the agent will assess.
    var gameModel: GKGameModel?

    /// The random source for this agent.
    var randomSource: GKRandom?

    /// Returns the best move for the current player.
    func bestMoveForActivePlayer() -> GKGameModelUpdate? {
        guard let state = gameModel as? AIAbstractGameState else { return defaultAction() }
        let answers: [AnyHashable: NSObjectProtocol] = [
            "canEscape?": state.isWin(for: state.player) as NSObjectProtocol,
            "nearExit": (state.exit.distance(between: state.player.position) < 64) as NSObjectProtocol
        ]
        guard let response = makeDecisionTree().findAction(forAnswers: answers) as? String else {
            return defaultAction()
        }
        return AIGameDecision(by: AIGamePlayerAction(rawValue: response) ?? .stop, with: 1)
    }

    func makeDecisionTree() -> GKDecisionTree {
        let dtree = GKDecisionTree(attribute: "canEscape?" as NSObjectProtocol)
        let root = dtree.rootNode

        root?.createBranch(value: true, attribute: "STOP" as NSObjectProtocol)
        root?.createBranch(value: false, attribute: "MOVE_LEFT" as NSObjectProtocol)

        return dtree
    }

    func defaultAction() -> AIGameDecision {
        return AIGameDecision(by: .stop, with: 0)
    }

}
