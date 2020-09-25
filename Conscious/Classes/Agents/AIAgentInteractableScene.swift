//
//  AIAgentInteractableScene.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/21/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SpriteKit

/// The agent's version of the game world.
///
/// This class is designed to make AI interactions easier, as well as make the scene assessable
/// so that an AI agent can play it.
class AIAgentInteractableScene: ChallengeGameScene {

    /// The agent that will control the player node.
    var agent: AIBaseAgent?

    // MARK: COMPUTED PROPERTIES

    /// Whether the exit door is active.
    private var exitActive: Bool {
        return self.exitNode?.active ?? false
    }

    /// The active inputs that link to the exit.
    private var activeExitInputs: [GameSignalSender] {
        return self.exitNode?.inputs.filter { input in input.active } ?? []
    }

    /// The inactive inputs that link to the exit.
    private var inactiveExitInputs: [GameSignalSender] {
        return self.exitNode?.inputs.filter { input in !input.active } ?? []
    }

    // MARK: METHODS

    /// Initialize the scene and agent.
    ///
    /// The scene will also add a watermark on the top of the scene to indicate this is an AI run.
    override func sceneDidLoad() {
        super.sceneDidLoad()
        guard let player = self.playerNode else { return }
        self.agent = AIBaseAgent(watching: player)

        let textNode = SKLabelNode(fontNamed: "Cabin Regular")
        textNode.color = .white
        textNode.text = "AI Demo"
        textNode.fontSize = 128.0
        textNode.zPosition = 10000

        textNode.position = self.camera?.position ?? CGPoint.zero
        textNode.alpha = 0.25
        let bounds = SKConstraint.distance(SKRange(upperLimit: 0), to: self.camera!)
        textNode.constraints = [bounds]

        self.addChild(textNode)

        let initialState = self.captureInitialState()
        print("Created initial game state: \(initialState)")
    }

    /// Update the state and perform an action.
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
    }

    /// Make an initial snapshot of the game state for a game model to use.
    /// - Returns: An agent game state that represents the initial state of the game.
    func captureInitialState() -> AIGameState {
        let gameState = AIGameState(
            at: self.currentTime,
            on: self.exitActive,
            with: (self.activeExitInputs, self.inactiveExitInputs),
            for: self.agent!
        )
        gameState.exitPosition = self.exitNode?.position ?? CGPoint.zero
        return gameState
    }

    /// Capture the current game scene as a state that an agent can interpret.
    /// - Returns: An agent game state.
    @available(*, deprecated, renamed: "captureInitialState")
    func capturedState() -> AIGameState {
        return self.captureInitialState()
    }

    /// Disable the keyboard input to this scene, preventing a human player from interacting
    /// with the scene.
    override func keyDown(with event: NSEvent) {
        self.run(SKAction.playSoundFileNamed("cantUse", waitForCompletion: false))
        print("AIAgentInteractableScene does not support keyboard events.")
    }

    /// Disable the keyboard input to this scene, preventing a human player from interacting
    /// with the scene.
    override func keyUp(with event: NSEvent) {
        print("AIAgentInteractableScene does not support keyboard events.")
    }
}
