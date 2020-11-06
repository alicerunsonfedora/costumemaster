//
//  AIGameStrategist.swift
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

/// An class that represents an agent in the game.
class AIGameStrategist {

    /// The internal game strategist that will be used to determine actions.
    var strategy: AIGameStrategy = AIRandomMoveStrategist()

    /// The state that the agent is assessing for best actions.
    var state: AIAbstractGameState {
        didSet {
            self.strategy.gameModel = state
        }
    }

    /// A string that describes the strategist to a receiver.
    var description: String {
        return "AIGameStrategist(type: \(self.strategy.description), state: \(self.state))"
    }

    /// A string that provides a simple description of the strategist to a receiver.
    var simpleDescription: String {
        "AIGameStrategist(with strategy: \(self.strategy.description))"
    }

    /// Initialize a strategist.
    /// - Parameter initialState: The initial state of the game world.
    init(with initialState: AIAbstractGameState) {
        self.state = initialState
        self.strategy.gameModel = initialState
        self.strategy.randomSource = GKARC4RandomSource()
    }

    /// Initialize a strategist.
    /// - Parameter initialState: The initial state of the game world.
    /// - Parameter budget: The maximum number of times the strategist can look forward to.
    init(with initialState: AIAbstractGameState, budget: Int) {
        self.state = initialState
        self.strategy.gameModel = initialState
        self.strategy.randomSource = GKARC4RandomSource()
    }

    /// Initialize a strategist.
    /// - Parameter strategy: The GKStrategist that will be used to determine best actions.
    /// - Parameter state: The initial state of the game world.
    init(with strategy: AIGameStrategy, reading state: AIAbstractGameState) {
        self.strategy = strategy
        self.strategy.gameModel = state
        self.state = state
    }

    /// Update the strategist's state to a new state for analysis.
    /// - Parameter state: The new state to update to.
    func update(with state: AIAbstractGameState) {
        self.state = state
    }

    /// Returns the nest best action for the player.
    func nextAction() -> AIGameDecision {
        guard let action = self.strategy.bestMoveForActivePlayer() as? AIGameDecision else {
            return AIGameDecision(by: .stop, with: 0)
        }
        return action
    }

}
