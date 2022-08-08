//
//  PressurePlate.swift
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

/// An input that uses pressure sensitivity to activate.
class GamePressurePlate: GameSignalSender {
    /// Whether the player left the range of the plate. Defaults to true.
    private var leftRange: Bool = true

    /// Whether the player is in range of the plate. Defaults to false.
    private var inRange: Bool = false

    /// Initialize a pressure plate.
    /// - Parameter position: The position of the plate in the matrix.
    public init(at position: CGPoint) {
        super.init(textureName: "plate", by: [.activeByPlayerIntervention], at: position)
        kind = .pressurePlate
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
    override public func shouldActivateOnIntervention(with player: Player?, objects: [SKSpriteNode?]) -> Bool {
        for object in objects where object?.physicsBody?.mass ?? 0 >= 50 {
            if object?.position.distance(between: self.position) ?? 0 < 64 { return true }
        }
        if player?.position.distance(between: position) ?? 0 <= 64 { return true }
        return false
    }

    /// Determine if the player is in range and play the pressure plate activation sound.
    override public func onActivate(with _: NSEvent?, player _: Player?) {
        leftRange = false
        if !inRange {
            runSequence {
                SKAction.run { self.inRange = true }
                SKAction.playSoundFileNamed("plateOn", waitForCompletion: true)
            }
        }
    }

    /// Determine if the player is out of range and play the pressure plate deactivation sound.
    override public func onDeactivate(with _: NSEvent?, player: Player?) {
        if let playerPos = player?.position {
            if playerPos.distance(between: position) >= 16, !leftRange {
                runSequence {
                    SKAction.run { self.leftRange = true }
                    SKAction.run { self.inRange = false }
                    SKAction.playSoundFileNamed("plateOff", waitForCompletion: true)
                }
            }
        }
    }
}
