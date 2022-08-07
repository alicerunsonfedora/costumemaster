//
//  GameComputer.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/4/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SpriteKit

/// A class representation of a computer.
class GameComputer: GameSignalSender {
    /// Initialize a computer.
    /// - Parameter position: The world matrix position of the computer.
    /// - Parameter softwareLock: Whether the computer is software locked (T1) or hardware locked (T2).
    init(at position: CGPoint, with softwareLock: Bool) {
        super.init(
            textureName: "computer_wallup\(softwareLock ? "_alt" : "")",
            by: [.activeOnToggle],
            at: position
        )
        kind = softwareLock ? .computerT1 : .computerT2
        instantiateBody(with: getWallPhysicsBody(with: "wall_edge_physics_mask"))
    }

    /// Required initializer for this class. Will result in a fatal error if you initialize the object this way.
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Activate the computer.
    /// - Parameter event: The event handler to listen to and track.
    /// - Parameter player: The player to watch and track.
    override func activate(with event: NSEvent?, player: Player?, objects _: [SKSpriteNode?]) {
        super.activate(with: event, player: player)
        if UserDefaults.playComputerSound {
            run(SKAction.playSoundFileNamed("computerPowerOn", waitForCompletion: true))
        }
    }
}
