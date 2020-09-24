//
//  AIBaseAgent.swift
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
import GameplayKit

/// The base class for an agent.
///
/// The agent is responsible for assessing a state and performing an action on it.
class AIBaseAgent: NSObject, GKGameModelPlayer {

    var playerId: Int = 0

    /// The player node that the agent controls.
    var player: Player

    /// Initialize an agent.
    /// - Parameter player: The player to let the agent control.
    init(watching player: Player) {
        self.player = player
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Move in a direction with respect to a unit size.
    /// - Parameter direction: The direction for the player node to move in.
    /// - Parameter unit: The unit size to move according to.
    func move(_ direction: PlayerMoveDirection, withRespectTo unit: CGSize) {
        let events = [
            SKAction.run {
                for _ in 1 ... 14 {
                    self.player.move(direction, unit: unit)
                }
            },
            SKAction.wait(forDuration: 2.5),
            SKAction.run { self.player.halt() }
        ]
        self.player.run(SKAction.sequence(events))
    }

    /// Create an action set.
    /// - Parameter action: The action that the agent will perform.
    /// - Returns: The action set that the agent will perform.
    func makeActionSet(for action: @escaping () -> Void) -> [SKAction] {
        return [SKAction.run(action), SKAction.wait(forDuration: 4.0)]
    }

    /// Run an action.
    /// - Parameter action: The action to perform.
    func run(action: [SKAction]?) {
        self.player.run(SKAction.sequence(action ?? []))
    }

}
