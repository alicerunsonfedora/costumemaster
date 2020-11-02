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

/// A strategist that will pick the best move based on a predetermined GKDecisionTree.
@available(OSX 10.15, *)
class AIPredeterminedTreeStrategist: AIGameStrategy {

    /// Returns the best move for the current player.
    override func bestMoveForActivePlayer() -> GKGameModelUpdate? {
        guard let state = gameModel as? AIAbstractGameState else { return defaultAction() }
        let answers = self.assess(state)

        guard var response = makeDecisionTree().findAction(forAnswers: answers) as? String else {
            return defaultAction()
        }

        // These special cases will help determine moves necessary to get closer to something using minimum
        // Manhattan distance.
        switch response {
        case "MOVE_EXIT_CLOSER": response = self.closestPathToExit(in: state)
        case "MOVE_INPUT_CLOSER": response = self.closestPath(to: self.closestInput(in: state), in: state)
        case "MOVE_RANDOM": response = self.moveRandom()
        default: break
        }

        return AIGameDecision(by: AIGamePlayerAction(rawValue: response) ?? .stop, with: 1)
    }

    /// Returns the decision tree that the agent will use to determine its next best move.
    /// - Returns: A decision tree with hard-coded suggestions.
    func makeDecisionTree() -> GKDecisionTree {
        let dtree = GKDecisionTree(attribute: "canEscape?".toProtocol())
        let root = dtree.rootNode

        let escapable = root?.createBranch(value: true, attribute: "nearExit?".toProtocol())
        let unescapable = root?.createBranch(value: false, attribute: "nearInput?".toProtocol())

        escapable?.createBranch(value: true, attribute: "STOP".toProtocol())
        escapable?.createBranch(value: false, attribute: "MOVE_EXIT_CLOSER".toProtocol())

        let relevance = unescapable?.createBranch(value: true, attribute: "inputRelevant?".toProtocol())
        unescapable?.createBranch(value: false, attribute: "MOVE_RANDOM".toProtocol())

        let activeInput = relevance?.createBranch(value: true, attribute: "inputActive?".toProtocol())
        relevance?.createBranch(value: false, attribute: "MOVE_EXIT_CLOSER".toProtocol())

        activeInput?.createBranch(value: true, attribute: "MOVE_EXIT_CLOSER".toProtocol())
        activeInput?.createBranch(value: false, attribute: "MOVE_INPUT_CLOSER".toProtocol())

        return dtree
    }

    /// Returns an assessment of the state based on a series of questions.
    /// - Returns: A dictionary of answers to questions the decision tree will ask to make a decision.
    func assess(_ state: AIAbstractGameState) -> [AnyHashable: NSObjectProtocol] {
        let closestInput = self.closestInput(in: state)
        return [
            "canEscape?": state.isWin(for: state.player) as NSObjectProtocol,
            "nearExit?": (state.exit.distance(between: state.player.position) < 64) as NSObjectProtocol,
            "nearInput?": (
                (closestInput?.position.distance(between: state.player.position) ?? CGFloat.zero) < 64
            ) as NSObjectProtocol,
            "inputActive?": (closestInput?.active ?? false) as NSObjectProtocol,
            "inputRelevant?": (closestInput?.outputs.contains(state.exit) ?? false) as NSObjectProtocol
        ]
    }

    /// Returns a default "stop" action.
    func defaultAction() -> AIGameDecision {
        return AIGameDecision(by: .stop, with: 0)
    }

    /// Make a random move.
    /// - Returns: A random move from the movement set of actions.
    func moveRandom() -> String {
        return (AIGamePlayerAction.movement().randomElement() ?? .stop).rawValue
    }

    /// Returns the closest input device relative to the player.
    /// - Parameter state: The state the agent will assess to determine which input to target.
    /// - Returns: The input device closest to the player, or nil.
    func closestInput(in state: AIAbstractGameState) -> AIAbstractGameSignalSender? {
        var minimum = CGFloat.infinity
        var input: AIAbstractGameSignalSender?
        for inp in state.inputs {
            let dist = inp.position.manhattanDistance(to: state.player.position)
            if dist < minimum {
                minimum = dist
                input = inp
            }
        }

        return input
    }

    /// Returns the action responsible for providing the closest path to the specified input.
    /// - Parameter input: The input for the agent to target.
    /// - Parameter state: The state the agent will assess to determine the move.
    func closestPath(to input: AIAbstractGameSignalSender?, in state: AIAbstractGameState) -> String {
        var minimumDistance = CGFloat.infinity
        var action: AIGamePlayerAction = .stop

        guard input != nil else { return action.rawValue }

        for possibleAction in AIGamePlayerAction.movement() {
            if let newState = state.copy() as? AIAbstractGameState {
                newState.apply(AIGameDecision(by: possibleAction, with: 0))
                let newDist = newState.player.position.manhattanDistance(to: input?.position ?? .zero)
                if newDist < minimumDistance {
                    minimumDistance = newDist
                    action = possibleAction
                }
            }
        }

        return action.rawValue
    }

    /// Returns the action responsible for providing the closest path to the exit.
    /// - Parameter state: The state the agent will assess to determine the move.
    func closestPathToExit(in state: AIAbstractGameState) -> String {
        var minimumDistance = CGFloat.infinity
        var action: AIGamePlayerAction = .stop

        for possibleAction in AIGamePlayerAction.movement() {
            if let newState = state.copy() as? AIAbstractGameState {
                newState.apply(AIGameDecision(by: possibleAction, with: 0))
                let newDist = newState.player.position.manhattanDistance(to: newState.exit)
                if newDist < minimumDistance {
                    minimumDistance = newDist
                    action = possibleAction
                }
            }
        }

        return action.rawValue
    }

}
