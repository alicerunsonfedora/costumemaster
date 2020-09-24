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
    override func sceneDidLoad() {
        super.sceneDidLoad()
        guard let player = self.playerNode else { return }
        self.agent = AIBaseAgent(watching: player)
    }

    /// Update the state and perform an action.
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
    }

    /// Capture the current game scene as a state that an agent can interpret.
    /// - Returns: An agent game state.
    func capturedState() -> AIGameState {
        return AIGameState(
            at: self.currentTime,
            on: self.exitActive,
            with: (self.activeExitInputs, self.inactiveExitInputs),
            for: self.agent!
        )
    }

    /// Disable the keyboard input to this scene, preventing a human player from interacting
    /// with the scene.
    override func keyDown(with event: NSEvent) {
        print("AIAgentInteractableScene does not support keyboard events.")
    }

    /// Disable the keyboard input to this scene, preventing a human player from interacting
    /// with the scene.
    override func keyUp(with event: NSEvent) {
        print("AIAgentInteractableScene does not support keyboard events.")
    }
}
