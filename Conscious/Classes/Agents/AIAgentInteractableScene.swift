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

    // MARK: COMPUTED PROPERTIES

    /// Whether the exit door is active.
    private var exitActive: Bool {
        return self.exitNode?.active ?? false
    }

    /// The number of inputs that are active and link up to the exit.
    private var activeExitInputs: Int {
        return self.switches.filter { (inp: GameSignalSender) in
            inp.receivers.contains(where: { rec in rec == self }) && inp.active
        }.count
    }

    /// The number of inputs that are inactive and link up to the exit.
    private var inactiveExitInputs: Int {
        return self.switches.filter { (inp: GameSignalSender) in
            inp.receivers.contains(where: { rec in rec == self }) && !inp.active
        }.count
    }

    // MARK: METHODS

    /// Assess the current game scene state and translate it to a score.
    /// - Important: This method must be implemented on subclasses. By default, this method
    /// will return a default state assessement of zero.
    /// - Returns: A score based on the game scene's state.
    func assessState() -> Int {
        return 0
    }

}
