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

    /// Initialize the game structure object.
    /// - Parameter texture: The texture for this sprite.
    /// - Parameter size: The size for this sprite.
    public init(with texture: SKTexture?, size: CGSize) {
        self.child = SKNode()
        super.init(texture: texture, color: .clear, size: size)
        self.child.position = self.position
        self.addChild(self.child)
    }

    /// Required initializer for this class. Will result in a fatal error if you initialize the object this way.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Instantiate the physics body for this sprite.
    /// - Parameter physicsBody: The physics body to assign to the sprite.
    public func instantiateBody(with physicsBody: SKPhysicsBody?) {
        self.child.physicsBody = physicsBody
    }

    /// Release the physics body from the sprite.
    public func releaseBody() {
        self.child.physicsBody = nil
    }

    /// Get the physics body for this sprite.
    public func getBody() -> SKPhysicsBody? {
        return self.child.physicsBody
    }

}
