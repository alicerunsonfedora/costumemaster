//
//  Player.swift
//  Conscious
//
//  Created by Marquis Kurt on 8/24/20.
//

import Foundation
import SpriteKit

class Player: SKSpriteNode {
    public var costume: PlayerCostumeType = .default
    private var costumeQueue: [PlayerCostumeType] = [.bird, .flashDrive, .sorceress]
    
    override init(texture: SKTexture?, color: NSColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.instantiatePhysicsBody(fromTexture: texture!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func instantiatePhysicsBody(fromTexture: SKTexture) {
        self.physicsBody = SKPhysicsBody(texture: fromTexture, size: fromTexture.textureRect().size)
        self.physicsBody?.restitution = 0.2
        self.physicsBody?.friction = 0.3
        self.physicsBody?.isDynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.mass = 76.02 / 4
    }
    
    /// Switch to the next available costume.
    public func nextCostume() -> PlayerCostumeType {
        self.costumeQueue.append(self.costume)
        self.costume = self.costumeQueue.remove(at: 0)
        self.texture = SKTexture(imageNamed: "Player (Idle, \(self.costume.rawValue))")
        return self.costume
    }
    
    /// Move the player by a specific amount.
    public func move(_ delta: CGVector) {
        self.physicsBody?.applyImpulse(delta)
    }
}
