//
//  AIGameStrategy.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/2/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import GameplayKit
import CranberrySprite

/// A base strategy class.
class AIGameStrategy: NSObject, GKStrategist {

    // MARK: - Properties

    /// The console that the strategy will send messages to.
    var console: ConsoleViewModel?

    /// The game model that will be used in the particular strategy.
    var gameModel: GKGameModel?

    /// The random source that the strategy can use.
    var randomSource: GKRandom?

    /// A list of positions for all of the active inputs the agent encounters.
    var activated: [CGPoint] = [] {
        didSet {
            console?.debug("List of active inputs updated: \(activated)")
        }
    }

    /// The closest input to the player.
    var closestInput: AIAbstractGameSignalSender?

    /// The closest object to the player.
    var closestObject: CGPoint?

    // MARK: - Strategy

    /// Returns the best move for the active player.
    func bestMoveForActivePlayer() -> GKGameModelUpdate? {
        console?.warn("bestMoveForActivePlayer has not been implemented for this agent.")
        return nil
    }

    // MARK: - Object Detection with Distance

    /// Returns the closest input device relative to the player.
    ///
    /// The closest input is determined by finding the minimum distance of all possible inputs that have not been
    /// added to the activated list.
    ///
    /// - Parameter state: The state the agent will assess to determine which input to target.
    /// - Returns: The input device closest to the player, or nil.
    public func closestInput(in state: AIAbstractGameState) -> AIAbstractGameSignalSender? {
        var minimum = CGFloat.infinity
        var input: AIAbstractGameSignalSender?
        for inp in state.inputs.filter({ but in !self.activated.contains(but.position) }) {
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
