//
//  AIGameScene.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/30/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SpriteKit
import GameplayKit

/// A game scene that an AI agent can control.
///
/// In the game scene, the player can provide a move budget and strategy to solve the puzzle. A default random move
/// strategist with a budget of ten moves is provided when these options aren't available.
///
/// - Important: Scenes that subclass the AI game scene must be running macOS 10.15 Catalina or higher.
@available(OSX 10.15, *) class AIGameScene: ChallengeGameScene {

    /// The strategist that will be playing this scene.
    var strategist: AIGameStrategist?

    /// Load the scene, set an initial state, and attempt to solve the puzzle.
    ///
    /// Agent testing mode will need to be enabled, and options for the agent type and move budget should be available.
    /// In cases where this isn't available, the random move agent will be used and will have a budget of ten moves.
    override func sceneDidLoad() {
        super.sceneDidLoad()
        guard let initialState = self.getState() else { return }
        self.strategist = self.getStrategy(with: initialState)

        if let strat = self.strategist {
            print("Initialized strategist: \(strat.description)")
        }

        self.run(SKAction.wait(forDuration: 5.0))

        print("Generating a strategy with \(AppDelegate.arguments.agentMoveRate ?? 10) moves...")
        self.repeatAfterMe(self.getPredeterminedStrategy(max: AppDelegate.arguments.agentMoveRate ?? 10))
    }

    /// Get a predetermined set of actions with a maximum budget.
    /// - Parameter budget: The maximum number of moves to get a strategy for.
    /// - Returns: A list of actions for the agent to take.
    func getPredeterminedStrategy(max budget: Int) -> [AIGameDecision] {
        var states = [AIGameDecision]()
        if let strat = self.strategist {
            for index in 1 ... budget {
                if strat.state.isWin(for: strat.state.player) {
                    print("Reached winning state after \(index) iterations.")
                    break
                }
                states.append(strat.nextAction())
                if let newState = self.getState() {
                    strat.state = newState
                }
            }
        }
        return states
    }

    /// Prevent the player from doing anything that could infl
    func blockInput() {
        print("Keyboard input is blocked in an AI game scene.")
        NSSound.beep()
    }

    /// Prevent keyboard input.
    override func keyDown(with event: NSEvent) {
        blockInput()
    }

    /// Capture the current scene as a game state.
    /// - Returns: An abstract version of the world as a game state that the agent can use.
    func getState() -> AIAbstractGameState? {
        guard let player = playerNode else { return nil }
        let state = AIAbstractGameState(with: AIAbstractGamePlayer(at: player.position, with: player.costumes))
        state.exit = self.exitNode?.position ?? CGPoint.zero

        var signals = [AIAbstractGameSignalSender]()
        for input in self.switches {
            var signal = AIAbstractGameSignalSender(
                position: input.position,
                active: input.active,
                outputs: input.receivers.map { out in out.position }
            )
            signal.timer = Int(input.cooldown)
            signals.append(signal)
        }

        var receivers = [AIAbstractGameSignalReceivable]()
        for output in self.receivers {
            receivers.append(
                AIAbstractGameSignalReceivable(active: output.active, location: output.position)
            )
        }

        state.inputs = signals
        state.outputs = receivers
        state.escapable = self.exitNode?.active ?? false

        return state
    }

    /// Apply a game state update to the scene.
    /// - Parameter state: The action that will be performed to change the state.
    func setUpdate(_ state: AIGameDecision) {
        var actions = [SKAction]()
        print("Applying state from action: \(state.action) (value \(state.value))")

        switch state.action {
        case .moveUp, .moveDown, .moveLeft, .moveRight:
            actions = [
                SKAction.run {
                    for _ in 1 ... 14 {
                        self.playerNode?.move(
                            PlayerMoveDirection.mappedFromAction(state.action),
                            unit: self.unit ?? CGSize(squareOf: 128)
                        )
                    }
                },
                SKAction.wait(forDuration: 2.5),
                SKAction.run { self.playerNode?.halt() }
            ]
        case .deployClone, .retractClone:
            actions = [
                SKAction.run {
                    self.playerNode?.copyAsObject()
                }
            ]
        case .pickup:
            actions = [
                SKAction.run {
                    for object in self.interactables {
                        object.attach(to: self.playerNode)
                    }
                }
            ]
        case .drop:
            actions = [
                SKAction.run {
                    for object in self.interactables {
                        object.resign(from: self.playerNode)
                    }
                }
            ]
        default:
            print("No actions to perform for \(state.action)")
            break
        }
        self.run(SKAction.sequence(actions))
    }

    /// Perform a set of actions and update the state of the scene.
    /// - Parameter moves: The list of actions to perform.
    func repeatAfterMe(_ moves: [AIGameDecision]) {
        var steps = [SKAction]()
        for action in moves {
            steps += [SKAction.run { self.setUpdate(action) }, SKAction.wait(forDuration: 2.5)]
        }
        self.run(SKAction.sequence(steps))
    }

    /// Get the appropriate strategy based on the type of input passed.
    /// - Parameter state: The state to create a strategist from.
    /// - Returns: An AI game strategist that will be used for the game scene. If none was provided, the random move
    /// strategist will be used instead.
    /// - Important: This function requires macOS 10.15 Catalina or later as it uses the new opaque type system.
    @available(OSX 10.15, *) func getStrategy(with state: AIAbstractGameState) -> some AIGameStrategist {
        switch AppDelegate.arguments.agentTestingType {
        case .randomMove:
            return AIGameStrategist(with: AIRandomMoveStrategist(), reading: state)
        default:
            print("WARN: Using random move agent because no fallback has been assigned and the argument supplied "
                  + "was invalid.")
            return AIGameStrategist(with: AIRandomMoveStrategist(), reading: state)
        }
    }

}
