//
//  AIGameStrategist.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/30/20.
//

import Foundation
import GameplayKit

class AIGameStrategist {

    var strategy: GKStrategist = GKMonteCarloStrategist()

    var state: AIAbstractGameState {
        didSet {
            self.strategy.gameModel = state
        }
    }

    init(with initialState: AIAbstractGameState) {
        self.state = initialState
        self.strategy.gameModel = initialState
        self.strategy.randomSource = GKARC4RandomSource()

        if let strat = self.strategy as? GKMonteCarloStrategist {
            strat.budget = 3
        }
    }

    init(with initialState: AIAbstractGameState, budget: Int) {
        self.state = initialState
        self.strategy.gameModel = initialState
        self.strategy.randomSource = GKARC4RandomSource()

        if let strat = self.strategy as? GKMonteCarloStrategist {
            strat.budget = budget
        }
    }

    
    init(with strategy: GKStrategist, reading state: AIAbstractGameState) {
        self.strategy = strategy
        self.strategy.gameModel = state
        self.state = state
    }

    func update(with state: AIAbstractGameState) {
        self.state = state
    }

    func nextAction() -> AIGameDecision {
        guard let action = self.strategy.bestMoveForActivePlayer() as? AIGameDecision else {
            return AIGameDecision(by: .stop, with: 0)
        }
        return action
    }

}
