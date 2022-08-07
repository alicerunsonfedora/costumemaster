//
//  GameStructureBlock.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 9/16/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SpriteKit

/// A structured sprite node with a child for a physics body.
///
/// This class is used to create objects with physics bodies that need to be pinned so that they don't move.
/// - Note: Currently, static sprites suffer from a drifting issue. Details on this issue can be found on the
/// [Apple Developer Forums](https://developer.apple.com/forums/thread/27057).
public class GameStructureObject: GameTileSpriteNode {
    /// The child node that hosts the physics body.
    private var child: SKNode

    /// Whether the structure object is locked.
    var locked: Bool = true

    /// Initialize the game structure object.
    /// - Parameter texture: The texture for this sprite.
    /// - Parameter size: The size for this sprite.
    public init(with texture: SKTexture?, size: CGSize) {
        child = SKNode()
        super.init(texture: texture, color: .clear, size: size)
        child.position = position
        addChild(child)
    }

    /// Required initializer for this class. Will result in a fatal error if you initialize the object this way.
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Instantiate the physics body for this sprite.
    /// - Parameter physicsBody: The physics body to assign to the sprite.
    public func instantiateBody(with physicsBody: SKPhysicsBody?) {
        child.physicsBody = physicsBody
    }

    /// Release the physics body from the sprite if the sprite is not locked.
    public func releaseBody() {
        if locked { return }
        child.physicsBody = nil
    }

    /// Get the physics body for this sprite.
    public func getBody() -> SKPhysicsBody? {
        child.physicsBody
    }
}
