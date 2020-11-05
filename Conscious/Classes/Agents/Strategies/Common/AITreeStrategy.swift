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
        let assessement: AIAbstractGameState.Assessement

        /// The fully processed action that the agent took.
        let action: AIGameDecision

        /// The action that was derived from the state.
        let derivedAction: String

        /// The internal score for this item.
        var score: Int = 0
    }

    // MARK: - State Assessements
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
    func assess(state: AIAbstractGameState) -> AIAbstractGameState.Assessement {
        var nearInput = false, nearObject = false

        if let input = self.closestInput {
            nearInput = input.position.distance(between: state.player.position) < 64
        }

        if let object = self.closestObject {
            nearObject = object.distance(between: state.player.position) < 64
        }

        let exitInputs = state.inputs.filter { (inp: AIAbstractGameSignalSender) in inp.outputs.contains(state.exit) }
        let allActive = exitInputs.allSatisfy { input in input.active } || false

        return AIAbstractGameState.Assessement(
            canEscape: state.isWin(for: state.player),
            nearExit: (state.exit.distance(between: state.player.position) < 36),
            nearInput: nearInput,
            inputActive: (self.closestInput?.active ?? false),
            inputRelevant: (self.closestInput?.outputs.contains(state.exit) ?? false),
            requiresObject: (self.closestInput?.kind == GameSignalKind.pressurePlate),
            requiresCostume: (
                [GameSignalKind.computerT2, GameSignalKind.computerT1].contains(self.closestInput?.kind) == true
            ),
            wearingCostume: self.wearingCorrectCostume(for: self.closestInput, in: state),
            hasObject: state.player.carryingItems,
            nearObject: nearObject,
            allInputsActive: allActive
        )
    }

    /// Returns whether the agent is wearing the correct costume for the selected input.
    /// - Parameter input: The input device to check for costume switching.
    /// - Parameter state: The state to assess for.
    func wearingCorrectCostume(for input: AIAbstractGameSignalSender?, in state: AIAbstractGameState) -> Bool {
        guard let realInput = input else { return false }
        switch realInput.kind {
        case .computerT1:
            return state.player.currentCostume == .flashDrive
        case .computerT2:
            return state.player.currentCostume == .bird
        default:
            return true
        }
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

        if let prevCloseInput = self.closestInput {
            for input in state.inputs where input.position == prevCloseInput.position && input.active {
                activated.append(input.position)
            }
        }

        // Assess the state and prepare it for submission to the decision tree.
        self.closestInput = self.closestInput(in: state)
        self.closestObject = self.closestObject(in: state)

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
            return self.closestPath(to: self.closestInput, in: state)
        case "MOVE_OBJ_CLOSER":
            console?.debug("MOVE_OBJ_CLOSER detected. Getting action that moves closest to closet object.")
            return self.closestPath(to: self.closestObject, in: state)
        case "MOVE_RANDOM":
            console?.warn("MOVE_RANDOM detected. Getting random movement action.")
            return self.moveRandom()
        default:
            console?.debug("No special processing needed on response.")
            return action
        }
    }

    /// Returns the default action from the response tree.
    func defaultAction() -> AIGameDecision {
        return AIGameDecision(by: .stop, with: 0)
    }

    /// Returns a random move.
    /// - Returns: A random move from the movement set of actions.
    func moveRandom() -> String {
        return (AIGamePlayerAction.movement().randomElement() ?? .stop).rawValue
    }
}
