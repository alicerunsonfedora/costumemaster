//
//  GameHeavyObject.swift
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

/// A class representation of a heavy object in the game.
///
/// Heavy objects can be manipulated by the player when wearing the sorceress costume.
class GameHeavyObject: GameTileSpriteNode {
    /// Whether the object is being carried by the player.
    public var carrying: Bool {
        parent is Player
    }

    /// Whether the object can be carried by the player. Defaults to true.
    public var canBeCarried: Bool = true

    /// Initialize a heavy object.
    /// - Parameter texture: The texture name of the heavy object.
    /// - Parameter location: The matrix location of the heavy object.
    public init(with texture: String, at location: CGPoint) {
        super.init(texture: SKTexture(imageNamed: texture), color: .clear, size: SKTexture(imageNamed: texture).size())
        worldPosition = location
        self.texture?.filteringMode = .nearest
        physicsBody = getHeavyObjectPhysicsBody(with: texture)
    }

    /// Required initializer for this class. Will result in a fatal error if you initialize the object this way.
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Attach the heavy object to the player.
    /// - Parameter player: The player object to attach to.
    public func attach(to player: Player?) {
        if parent == player || !canBeCarried { return }
        guard let costume = player?.costume else { return }
        if costume == .sorceress, player?.position.distance(between: position) ?? 99 <= 64 {
            removeFromParent()
            player?.addChild(self)
        }
    }

    /// Resign the attachment status from the player.
    /// - Parameter player: The player object to detach or resign from.
    public func resign(from player: Player?) {
        if parent != player || !canBeCarried { return }
        if let pos = player?.position {
            position = CGPoint(x: pos.x - 16, y: pos.y)
            removeFromParent()
            player?.parent?.addChild(self)
        }
    }
}
