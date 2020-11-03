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
        guard let state = gameModel as? AIAbstractGameState else {
            console?.error("Supplied game state is not an AI game state. Returning default action.")
            return defaultAction()
        }
        let answers = self.assess(state)

        guard var response = makeDecisionTree().findAction(forAnswers: answers) as? String else {
            console?.error("Response from tree was not valid. Returning default action.")
            return defaultAction()
        }
        console?.debug("Received response from decision tree: \(response)")

        // These special cases will help determine moves necessary to get closer to something using minimum
        // Manhattan distance.
        switch response {
        case "MOVE_EXIT_CLOSER":
            console?.debug("MOVE_EXIT_CLOSER detected. Getting action that moves closest to exit.")
            response = self.closestPathToExit(in: state)
        case "MOVE_INPUT_CLOSER":
            console?.debug("MOVE_INPUT_CLOSER detected. Getting action that moves closest to closet input.")
            response = self.closestPath(to: self.closestInput(in: state), in: state)
        case "MOVE_OBJ_CLOSER":
            console?.debug("MOVE_OBJ_CLOSER detected. Getting action that moves closest to closet object.")
            response = self.closestPath(to: self.closestObject(in: state), in: state)
        case "MOVE_RANDOM":
            console?.warn("MOVE_RANDOM detected. Getting random movement action.")
            response = self.moveRandom()
        default:
            console?.debug("No special processing needed on response.")
        }

        return AIGameDecision(by: AIGamePlayerAction(rawValue: response) ?? .stop, with: 1)
    }

    /// Returns the decision tree that the agent will use to determine its next best move.
    /// - Returns: A decision tree with hard-coded suggestions.
    func makeDecisionTree() -> GKDecisionTree {
        let dtree = GKDecisionTree(attribute: "canEscape?".toProtocol())
        let root = dtree.rootNode

        let canEscape = root?.createBranch(value: true, attribute: "nearExit?".toProtocol())
        canEscape?.createBranch(value: true, attribute: "STOP".toProtocol())
        canEscape?.createBranch(value: false, attribute: "MOVE_EXIT_CLOSER".toProtocol())

        let cannotEscape = root?.createBranch(value: false, attribute: "nearInput?".toProtocol())
        let activeInput = cannotEscape?.createBranch(value: true, attribute: "inputActive?".toProtocol())
        let allActive = activeInput?.createBranch(value: true, attribute: "allInputsActive?".toProtocol())
        allActive?.createBranch(value: true, attribute: "MOVE_EXIT_CLOSER".toProtocol())
        allActive?.createBranch(value: false, attribute: "MOVE_RANDOM".toProtocol())

        let needsObj = activeInput?.createBranch(value: false, attribute: "requiresObject?".toProtocol())
        let hasObj = needsObj?.createBranch(value: true, attribute: "hasObject?".toProtocol())
        hasObj?.createBranch(value: true, attribute: "DROP".toProtocol())
        hasObj?.createBranch(value: false, attribute: "MOVE_OBJECT_CLOSER".toProtocol())

        let requiresCostume = needsObj?.createBranch(value: false, attribute: "requiresCostume?".toProtocol())
        requiresCostume?.createBranch(value: true, attribute: "NEXT_COSTUME".toProtocol())

        let inputImportant = requiresCostume?.createBranch(value: false, attribute: "inputRelevant?".toProtocol())
        inputImportant?.createBranch(value: true, attribute: "ACTIVATE".toProtocol())
        inputImportant?.createBranch(value: false, attribute: "MOVE_RANDOM".toProtocol())

        let nearObj = cannotEscape?.createBranch(value: false, attribute: "nearObj?".toProtocol())
        nearObj?.createBranch(value: true, attribute: "PICK_UP".toProtocol())
        nearObj?.createBranch(value: false, attribute: "MOVE_INPUT_CLOSER".toProtocol())

        return dtree
    }

    /// Returns an assessment of the state based on a series of questions.
    /// - Returns: A dictionary of answers to questions the decision tree will ask to make a decision.
    func assess(_ state: AIAbstractGameState) -> [AnyHashable: NSObjectProtocol] {
        let closestInput = self.closestInput(in: state)
        let closetObj = self.closestObject(in: state)
        var nearInput = false, nearObject = false

        if let input = closestInput {
            nearInput = input.position.distance(between: state.player.position) < 64
        }

        if let object = closetObj {
            nearObject = object.distance(between: state.player.position) < 64
        }

        let exitInputs = state.inputs.filter { (inp: AIAbstractGameSignalSender) in inp.outputs.contains(state.exit) }
        let allActive = exitInputs.allSatisfy { input in input.active } || false

        return [
            "canEscape?": state.isWin(for: state.player) as NSObjectProtocol,
            "nearExit?": (state.exit.distance(between: state.player.position) < 36) as NSObjectProtocol,
            "nearInput?": nearInput as NSObjectProtocol,
            "inputActive?": (closestInput?.active ?? false) as NSObjectProtocol,
            "inputRelevant?": (closestInput?.outputs.contains(state.exit) ?? false) as NSObjectProtocol,
            "requiresObject?": (closestInput?.kind == GameSignalKind.pressurePlate) as NSObjectProtocol,
            "requiresCostume?": (
                [GameSignalKind.computerT2, GameSignalKind.computerT1].contains(closestInput?.kind) == true
            ) as NSObjectProtocol,
            "hasObject?": state.player.carryingItems as NSObjectProtocol,
            "nearObj?": nearObject as NSObjectProtocol,
            "allInputsActive?": allActive as NSObjectProtocol
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

        if input != nil {
            console?.debug(
                "Closest input found at \(input?.prettyPosition ?? .zero) (scene distance: \(minimum))"
            )
        } else { console?.warn("Agent is not close to any input.") }
        return input
    }

    /// Returns the closest object relative to the player.
    /// - Parameter state: The state the agent will assess to determine which object to target.
    /// - Returns: The input device closest to the player, or nil.
    func closestObject(in state: AIAbstractGameState) -> CGPoint? {
        var minimum = CGFloat.infinity
        var object: CGPoint?
        for obj in state.interactableObjects {
            let dist = obj.manhattanDistance(to: state.player.position)
            if dist < minimum {
                minimum = dist
                object = obj
            }
        }

        if object != nil {
            console?.debug(
                "Closest object found at \(object ?? .zero) (scene distance: \(minimum))"
            )
        } else { console?.warn("Agent is not close to any object.") }
        return object
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

        console?.debug("Action \(action) makes shortest distance (\(minimumDistance)) to \(input?.position ?? .zero).")
        return action.rawValue
    }

    /// Returns the action responsible for providing the closest path to the specified object.
    /// - Parameter object: The object for the agent to target.
    /// - Parameter state: The state the agent will assess to determine the move.
    func closestPath(to object: CGPoint?, in state: AIAbstractGameState) -> String {
        var minimumDistance = CGFloat.infinity
        var action: AIGamePlayerAction = .stop

        guard object != nil else { return action.rawValue }

        for possibleAction in AIGamePlayerAction.movement() {
            if let newState = state.copy() as? AIAbstractGameState {
                newState.apply(AIGameDecision(by: possibleAction, with: 0))
                let newDist = newState.player.position.manhattanDistance(to: object ?? .zero)
                if newDist < minimumDistance {
                    minimumDistance = newDist
                    action = possibleAction
                }
            }
        }

        console?.debug("Action \(action) makes shortest distance (\(minimumDistance)) to \(object ?? .zero).")
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

        console?.debug("Action \(action) makes shortest distance (\(minimumDistance)) to exit.")
        return action.rawValue
    }

}
