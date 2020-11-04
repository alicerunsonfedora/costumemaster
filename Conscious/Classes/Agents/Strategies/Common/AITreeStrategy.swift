//
//  AITreeStrategy.swift
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

/// A subclass of the AI game strategy designed for use with decision trees.
///
/// Agents that use the tree strategy will attempt to use a state assessement and determine the best action by
/// submitting that assessement to a decision tree, depending on the tree's implementation.
@available(OSX 10.15, *)
class AITreeStrategy: AIGameStrategy {

    /// A history of all of the previous assessements this agent has made.
    var history: [ActionHistoryItem] = []

    /// Whether the agent should record all of its previous attempts. Defaults to false.
    var recordsHistory: Bool = false

    /// A list of all of the available actions the agent can make.
    var actions: [NSObjectProtocol] {
        AIGamePlayerAction.allCases.map { act in act.rawValue.toProtocol() } +
            ["MOVE_RANDOM", "MOVE_EXIT_CLOSER", "MOVE_INPUT_CLOSER", "MOVE_OBJ_CLOSER"]
            .map { string in string.toProtocol() }
    }
    /// A structure that represents an action history item.
    public struct ActionHistoryItem {

        /// The assessement of the state.
        let assessement: StateAssessement

        /// The fully processed action that the agent took.
        let action: AIGameDecision

        /// The action that was derived from the state.
        let derivedAction: String

        /// The internal score for this item.
        var score: Int = 0
    }

    // MARK: - State Assessements

    /// A structure that defines a state assessement.
    public struct StateAssessement {

        /// Can the agent escape?
        let canEscape: Bool

        /// Is the agent near the exit?
        let nearExit: Bool

        /// Is the agent near an input device?
        let nearInput: Bool

        /// Is the closest input nearby active?
        let inputActive: Bool

        /// Is the closest input device relevant to opening the exit?
        let inputRelevant: Bool

        /// Does the closest input require a heavy object?
        let requiresObject: Bool

        /// Does the closest input require a specific costume?
        let requiresCostume: Bool

        /// Does the agent have an object in its inventory?
        let hasObject: Bool

        /// Is the agent near an object?
        let nearObject: Bool

        /// Are all of the inputs that send signals to the exit door active?
        let allInputsActive: Bool

        /// Returns a copy of the assessement as an example for decision trees.
        func toList() -> [AnyHashable] {
            [
                canEscape,
                nearExit,
                nearInput,
                inputActive,
                inputRelevant,
                requiresObject,
                requiresCostume,
                hasObject,
                nearObject,
                allInputsActive
            ]
        }

        /// Returns a copy of the assessement as a dictionary suitable for decision trees.
        func toDict() -> [AnyHashable: NSObjectProtocol] {
            return [
                "canEscape?": self.canEscape as NSObjectProtocol,
                "nearExit?": self.nearExit as NSObjectProtocol,
                "nearInput?": self.nearInput as NSObjectProtocol,
                "inputActive?": self.inputActive as NSObjectProtocol,
                "inputRelevant?": self.inputRelevant as NSObjectProtocol,
                "requiresObject?": self.requiresObject as NSObjectProtocol,
                "requiresCostume?": self.requiresCostume as NSObjectProtocol,
                "hasObject?": self.hasObject as NSObjectProtocol,
                "nearObj?": self.nearObject as NSObjectProtocol,
                "allInputsActive?": self.allInputsActive as NSObjectProtocol
            ]
        }
    }

    /// Returns a given decision tree that the agent will use to grab its next best move.
    /// - Returns: A decision tree (GKDecisionTree)
    /// - Important: This method must be overridden in all subclasses; otherwise, the decision tree may not be able
    /// to generate an answer, and the agent will use a fallback action.
    func makeDecisionTree() -> GKDecisionTree {
        console?.warn("makeDecisionTree has not been implemented for this agent. Returning an empty decision tree.")
        return GKDecisionTree()
    }

    /// Returns an active assessement of the given state.
    /// - Parameter state: The state to assess.
    func assess(state: AIAbstractGameState) -> StateAssessement {
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

        return StateAssessement(
            canEscape: state.isWin(for: state.player),
            nearExit: (state.exit.distance(between: state.player.position) < 36),
            nearInput: nearInput,
            inputActive: (closestInput?.active ?? false),
            inputRelevant: (closestInput?.outputs.contains(state.exit) ?? false),
            requiresObject: (closestInput?.kind == GameSignalKind.pressurePlate),
            requiresCostume: (
                [GameSignalKind.computerT2, GameSignalKind.computerT1].contains(closestInput?.kind) == true
            ),
            hasObject: state.player.carryingItems,
            nearObject: nearObject,
            allInputsActive: allActive
        )
    }

    // MARK: - Best Move for Player

    /// Returns the best move for the active player.
    ///
    /// The agent will attempt to create an assessement of the current state and receive a response from
    /// `AITreeStrategy.makeDecisionTree`. Any special processing after the response collection will be performed
    /// before returning the action back to the strategist.
    ///
    /// - Note: This function may be overridden in subclasses, if necessary.
    /// - Precondition: The `AITreeStrategy.makeDecisionTree` must be fully implemented.
    override func bestMoveForActivePlayer() -> GKGameModelUpdate? {
        // Capture the current state.
        guard let state = gameModel as? AIAbstractGameState else {
            console?.error("Supplied game state is not an AI game state. Returning default action.")
            return defaultAction()
        }

        // Assess the state and prepare it for submission to the decision tree.
        let assessement = self.assess(state: state)

        // Get a response from the decision tree.
        guard var response = makeDecisionTree().findAction(forAnswers: assessement.toDict()) as? String else {
            console?.error("Response from tree was not valid. Returning default action.")
            let action = defaultAction()
            if recordsHistory {
                history.append(
                    ActionHistoryItem(
                        assessement: assessement,
                        action: action,
                        derivedAction: action.action.rawValue,
                        score: -100
                    )
                )
            }
            return action
        }
        console?.debug("Received response from decision tree: \(response)")

        // The process function will look for special responses and convert them in actual actions based on context.
        let originalResponse = response
        response = self.process(response, from: state)
        let action = AIGameDecision(by: AIGamePlayerAction(rawValue: response) ?? .stop, with: 1)

        // If we can record our actions, create a history item and add it to the list.
        if recordsHistory {
            history.append(
                ActionHistoryItem(
                    assessement: assessement,
                    action: action,
                    derivedAction: originalResponse
                )
            )
        }

        return action
    }

    // MARK: - Action Processing

    /// Returns a specified action if the action is a special keyword.
    /// - Parameter action: The action to process.
    /// - Parameter state: The current state the action derived from.
    func process(_ action: String, from state: AIAbstractGameState) -> String {
        switch action {
        case "MOVE_EXIT_CLOSER":
            console?.debug("MOVE_EXIT_CLOSER detected. Getting action that moves closest to exit.")
            return self.closestPath(in: state)
        case "MOVE_INPUT_CLOSER":
            console?.debug("MOVE_INPUT_CLOSER detected. Getting action that moves closest to closet input.")
            return self.closestPath(to: self.closestInput(in: state), in: state)
        case "MOVE_OBJ_CLOSER":
            console?.debug("MOVE_OBJ_CLOSER detected. Getting action that moves closest to closet object.")
            return self.closestPath(to: self.closestObject(in: state), in: state)
        case "MOVE_RANDOM":
            console?.warn("MOVE_RANDOM detected. Getting random movement action.")
            return self.moveRandom()
        default:
            console?.debug("No special processing needed on response.")
            return action
        }
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

    // MARK: - Object Detection with Distance

    /// Returns the closest input device relative to the player.
    /// - Parameter state: The state the agent will assess to determine which input to target.
    /// - Returns: The input device closest to the player, or nil.
    public func closestInput(in state: AIAbstractGameState) -> AIAbstractGameSignalSender? {
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
    func closestPath(in state: AIAbstractGameState) -> String {
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
