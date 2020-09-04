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

class GameHeavyObject: SKSpriteNode {

    public let location: CGPoint

    public var carrying: Bool {
        return self.parent is Player
    }

    public init(with texture: String, at location: CGPoint) {
        self.location = location
        super.init(texture: SKTexture(imageNamed: texture), color: .clear, size: SKTexture(imageNamed: texture).size())
        self.texture?.filteringMode = .nearest
        self.physicsBody = getHeavyObjectPhysicsBody(with: texture)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func attach(to player: Player?) {
        if self.parent == player { return }
        guard let costume = player?.costume else { return }
        if costume == .sorceress && player?.position.distance(between: self.position) ?? 99 <= 64 {
            self.removeFromParent()
            player?.addChild(self)
        }

    }

    public func resign(from player: Player?) {
        if self.parent != player { return }
        if let pos = player?.position {
            self.position = CGPoint(x: pos.x - 16, y: pos.y)
            self.removeFromParent()
            player?.parent?.addChild(self)
        }

    }

}
