//
//  AIYellowConverseStrategist.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/10/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import GameplayKit
import CoreML

/// A decision tree-based agent that uses a model trained with CoreML to produce results.
class AIYellowConverseStrategist: AITreeStrategy {

    /// The ML model the agent will use to make decisions.
    var model: YellowConverse?

    /// Initialize the strategist.
    override init() {
        super.init()

        do {
            self.model = try YellowConverse(contentsOf: YellowConverse.urlOfModelInThisBundle)
            console?.debug("Loaded decision tree model into the agent.")
        } catch {
            console?.error("Failed to load ML model for the agent.")
            self.model = nil
        }
    }

    /// Returns the best move for the active player.
    override func bestMoveForActivePlayer() -> GKGameModelUpdate? {
        // Set up the state.
        guard let state = gameModel as? AIAbstractGameState else {
            console?.error("Failed to convert game model to abstract game state. Returning the default action.")
            return defaultAction()
        }

        // Check our input list for previously activated inputs.
        if let prevCloseInput = self.closestInput {
            for input in state.inputs where input.position == prevCloseInput.position && input.active {
                activated.append(input.position)
            }
        }

        // Get the closest input and object.
        self.closestInput = self.closestInput(in: state)
        self.closestObject = self.closestObject(in: state)

        // Assess the state and convert it to an input the ML model can understand.
        let mlInput = self.assessToInput(state: state)

        // Attempt to read the ML model and produce the correct action.
        do {
            let response = try self.model?.prediction(input: mlInput)
            let result = response?.action ?? defaultAction().action.rawValue
            console?.debug("Received response from ML model (or provided default): \(result)")
            console?.debug("Response probability for \(result): \(response?.actionProbability[result] ?? 0.0)%")

            let processedResponse = self.process(result, from: state)
            let action = AIGameDecision(by: AIGamePlayerAction(rawValue: processedResponse) ?? .stop, with: 0)
            return action
        }

        // Otherwise, return the default action.
        catch {
            console?.error("Failed to get the response from the ML model. Returning default action.")
            return defaultAction()
        }
    }

    /// Returns an input that satisfies the ML model with a state assessement.
    /// - Parameter state The state to make an assessement for.
    func assessToInput(state: AIAbstractGameState) -> YellowConverseInput {
        let data = self.assess(state: state)
        return YellowConverseInput(
            canEscape: data.canEscape.toPythonString(),
            nearExit: data.nearExit.toPythonString(),
            nearInput: data.nearInput.toPythonString(),
            inputActive: data.inputActive.toPythonString(),
            inputRelevant: data.inputRelevant.toPythonString(),
            requiresObject: data.requiresObject.toPythonString(),
            requiresCostume: data.requiresCostume.toPythonString(),
            wearingCostume: data.wearingCostume.toPythonString(),
            hasObject: data.hasObject.toPythonString(),
            nearObject: data.nearObject.toPythonString(),
            allInputsActive: data.allInputsActive.toPythonString()
        )
    }

}
