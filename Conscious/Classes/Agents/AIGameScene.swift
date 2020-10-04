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
class AIGameScene: ChallengeGameScene {

    /// The strategist that will be playing this scene.
    var strategist: AIGameStrategist?

    /// Load the scene and set an initial state.
    override func sceneDidLoad() {
        super.sceneDidLoad()
        guard let initialState = self.getState() else { return }
        self.strategist = AIGameStrategist(with: initialState, budget: 3)
        // Write the state management code here.

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

}
