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

#if canImport(SwiftUI)
import SwiftUI
#endif

/// A game scene that an AI agent can control.
///
/// In the game scene, the player can provide a move budget and strategy to solve the puzzle. A default random move
/// strategist with a budget of one move is provided when these options aren't available.
///
/// - Important: Scenes that subclass the AI game scene must be running macOS 10.15 Catalina or higher.
class AIGameScene: ChallengeGameScene {

    /// The console view model that hosts all of the console messages.
    var console = ConsoleViewModel()

    /// The strategist that will be playing this scene.
    var strategist: AIGameStrategist?

    /// The console window associated with this scene.
    var consoleWindowController: NSWindowController?

    /// Load the scene, set an initial state, and attempt to solve the puzzle.
    ///
    /// Agent testing mode will need to be enabled, and options for the agent type and move budget should be available.
    /// In cases where this isn't available, the random move agent will be used and will have a budget of one move.
    override func sceneDidLoad() {
        console.debug("Setting up level for AI interaction.", silent: true)
        super.sceneDidLoad()

        console.success("Loaded level successfully: \(self.name ?? "AI Level")", silent: true)

        guard let initialState = self.getState() else {
            console.error("Could not capture the initial state. Aborting simulation.")
            return
        }
        console.info("Captured initial state: \(initialState)")

        self.strategist = self.getStrategy(with: initialState)

        if let strat = self.strategist {
            console.debug("Initialized strategist: \(strat.strategy.description)")
        }

        // Wait until the window has opened (generally ~5 sec) before starting to solve.
        self.run(SKAction.wait(forDuration: 5.0))

        // Start attempting to solve the puzzle, creating a set of moves in batches based on user preferences.
        // This should help prevent infinite recursion in such a way that prevents the window from ever showing.
        console.debug("Move generation rate set to: \(AppDelegate.arguments.agentMoveRate ?? 1) moves per update.")
        self.solve(with: AppDelegate.arguments.agentMoveRate)
    }

    /// Close the simulator console and prevent scene-saving.
    override func willMove(from view: SKView) {
        consoleWindowController?.close()
    }

    /// Close out of the current console and re-initialize the console.
    override func didMove(to view: SKView) {
        consoleWindowController?.close()
        initConsole()
        console.info("Initialized simulation console.", silent: true)
    }

    /// Attempt to solve the level by generating batches of actions to run infinitely or until the puzzle is solved.
    ///
    /// To prevent the game from locking up due to infinite recursion, this function is designed to make a bunch of
    /// pre-determined moves in batches of the maximum agent budget, act on them, and repeat this process.
    ///
    /// - Parameter rate: The maximum rate that the agent can make moves. If none is provided, it will use a default
    /// of 10.
    func solve(with rate: Int?) {
        // Set up the initial values.
        guard let agent = self.strategist else { return }
        var solvedState = agent.state.isWin(for: agent.state.player)
        var moves = [AIGameDecision]()

        // When the state is assessed, removing the action with the "AI Thread" key will stop execution.
        let assessState = SKAction.run {
            solvedState = agent.state.isWin(for: agent.state.player)
            if solvedState {
                self.console.debug("State is a winning state. AI Thread will be killed.")
                self.console.success("Simulation finished with winning state in \(self.currentTime) seconds.")
                self.removeAction(forKey: "AI Thread")
            }
        }

        // Generate a set of moves and run those moves accordingly.
        let generateAction = SKAction.run {
            moves = self.strategize(with: rate ?? 1)
            self.console.info("Move queue populated with \(moves.count) moves.")
        }

        let actOnMoves = SKAction.run { self.repeatAfterMe(moves) }

        // Pause for at least two seconds and the budget rate so that all actions can be played properly.
        let pause = SKAction.wait(forDuration: 2.0 + (Double(rate ?? 10) * 2.5))

        let sequence = solvedState ? [] : [assessState, generateAction, actOnMoves, pause]

        // Create the action for repeating these moves and run them with the "AI Thread" key.
        let repeatable = SKAction.repeatForever(SKAction.sequence(sequence))
        self.run(repeatable, withKey: "AI Thread")
    }

    /// Get a predetermined set of actions with a maximum budget.
    ///
    /// After every move, the state is reassesed. If the state resulting from an action causes the solution, no further
    /// actions will be generated.
    ///
    /// - Parameter budget: The maximum number of moves to get a strategy for.
    /// - Returns: A list of actions for the agent to take.
    /// - Complexity: This method takes O(n) time since, at the very worst case, a list of actions with the max
    /// budget can be created.
    func strategize(with budget: Int) -> [AIGameDecision] {
        var states = [AIGameDecision]()
        if let strat = self.strategist {
            for index in 1 ... budget {
                if strat.state.isWin(for: strat.state.player) {
                    console.debug("Reached winning state after \(index) iterations. Stopping batch generation...")
                    break
                }
                let move = strat.nextAction()
                states.append(move)
                if let newState = self.getState() {
                    strat.state = newState
                    strat.state.apply(move)
                }
            }
        }
        return states
    }

    /// Prevent the player from doing anything that could influence state updates.
    func blockInput() {
        console.error("Keyboard input is blocked in an AI game scene.")
        NSSound.beep()
    }

    /// Prevent keyboard input.
    override func keyDown(with event: NSEvent) {
        blockInput()
    }

    /// Run the AI's version of didFinishUpdate.
    override func didFinishUpdate() {
        self.aiFinish()
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
                kind: input.kind,
                position: input.position,
                prettyPosition: input.worldPosition,
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
    /// - Parameter action: The action that will be performed to change the state.
    func apply(_ action: AIGameDecision) {
        var actions = [SKAction]()
        console.debug("(Value: \(action.value))\tApplying action '\(action.action)' to current state.")

        switch action.action {
        case .moveUp, .moveDown, .moveLeft, .moveRight:
            actions = [
                SKAction.run {
                    for _ in 1 ... 14 {
                        self.playerNode?.move(
                            PlayerMoveDirection.mappedFromAction(action.action),
                            unit: self.unit ?? CGSize(squareOf: 128)
                        )
                    }
                },
                SKAction.wait(forDuration: 2.5),
                SKAction.run { self.playerNode?.halt() }
            ]
        case .switchToNextCostume, .switchToPreviousCostume:
            actions = [
                SKAction.run {
                    _ = action.action == .switchToNextCostume
                        ? self.playerNode?.nextCostume()
                        : self.playerNode?.previousCostume()
                }
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
        case .activate:
            actions = [
                SKAction.run {
                    self.checkInputStates(NSEvent())
                }
            ]
        default:
            self.playerNode?.halt()
        }
        self.run(SKAction.sequence(actions))
    }

    /// Perform a set of actions and update the state of the scene.
    /// - Parameter moves: The list of actions to perform.
    func repeatAfterMe(_ moves: [AIGameDecision]) {
        var steps = [SKAction]()
        for action in moves {
            steps += [SKAction.run { self.apply(action) }, SKAction.wait(forDuration: 2.5)]
        }
        self.run(SKAction.sequence(steps))
    }

    /// Get the appropriate strategy based on the type of input passed.
    /// - Parameter state: The state to create a strategist from.
    /// - Returns: An AI game strategist that will be used for the game scene. If none was provided, the random move
    /// strategist will be used instead.
    /// - Important: This function requires macOS 10.15 Catalina or later as it uses the new opaque type system.
    func getStrategy(with state: AIAbstractGameState) -> some AIGameStrategist {
        var strategist = AIGameStrategist(with: state)

        switch AppDelegate.arguments.agentTestingType {
        case .randomMove:
            strategist = AIGameStrategist(with: AIRandomMoveStrategist(), reading: state)
        case .randomWeightMove:
            strategist = AIGameStrategist(with: AIRandomWeightedStrategist(), reading: state)
        case .reflex:
            strategist = AIGameStrategist(with: AIReflexStrategist(), reading: state)
        case .predeterminedTree:
            strategist = AIGameStrategist(with: AIPredeterminedTreeStrategist(), reading: state)
        case .yellowConverse:
            strategist = AIGameStrategist(with: AIYellowConverseStrategist(), reading: state)
        default:
            console.error("Agent type \(AppDelegate.arguments.agentTestingType.rawValue) cannot be found.")
            console.warn("Using fallback agent \"randomMove\".")
            strategist = AIGameStrategist(with: AIRandomMoveStrategist(), reading: state)
        }

        strategist.strategy.console = self.console
        return strategist
    }

}
