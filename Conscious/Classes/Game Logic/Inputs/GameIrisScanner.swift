//
//  GameIrisScanner.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 10/9/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SpriteKit

/// A class that represents an iris scanner in the game.
///
/// Iris scanners are different from most inputs in that it works both by intervention and on a timer. When a player
/// enters its radius, the input will activate for a specified period of time (default is 5 seconds).
class GameIrisScanner: GameSignalSender {
    /// Initialize an iris scanner.
    /// - Parameter position: The world matrix position of the iris scanner.
    init(at position: CGPoint) {
        super.init(
            textureName: "iris_scanner",
            by: [.activeByPlayerIntervention, .activeOnTimer],
            at: position, with: 5.0
        )
        kind = .trigger
        instantiateBody(with: getWallPhysicsBody(with: "wall_edge_physics_mask"))
    }

    /// Required initializer for this class. Will result in a fatal error if you initialize the object this way.
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Whether the input should turn on/off based on player or object intervention.
    /// - Parameter player: The player to listen to for intervention.
    /// - Parameter objects: The objects to listen to for intervention.
    /// - Returns: Whether the input should activate given the intervention criteria.
    override func shouldActivateOnIntervention(with player: Player?, objects _: [SKSpriteNode?]) -> Bool {
        guard let play = player else { return false }
        return play.costume == .default && play.position.distance(between: position) < 192
    }

    /// Run any post-activation methods.
    /// - Parameter event: The event handler that triggered the activation.
    /// - Parameter player: The player that triggered the activation.
    override func onActivate(with _: NSEvent?, player _: Player?) {}

    /// Run any post-deactivation methods.
    /// - Parameter event: The event handler that triggered the activation.
    /// - Parameter player: The player that triggered the activation.
    override func onDeactivate(with _: NSEvent?, player _: Player?) {}
}
