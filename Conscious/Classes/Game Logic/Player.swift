//
//  Player.swift
//  Conscious
//
//  Created by Marquis Kurt on 8/24/20.
//

import Foundation
import SpriteKit

/// A class representation of the game player.
///
/// The player class is a subclass of SKSpriteNode that contains additional logic for handling player changes such as
/// costume switching.
class Player: SKSpriteNode {

    // MARK: STORED PROPERTIES

    /// Thre current costume the player is wearing.
    public var costume: PlayerCostumeType = .default

    /// A queue of all available costumes the olayer can switch to.
    private var costumeQueue: [PlayerCostumeType] = [.bird, .flashDrive, .sorceress]

    /// Initialize the player.
    /// - Parameter texture: A texture to apply to the sprite.
    /// - Parameter allowCostumes: A list of all of the allowed costumes for a particular level.
    public init(texture: SKTexture?, allowCostumes: [PlayerCostumeType]) {
        super.init(texture: texture, color: NSColor.clear, size: texture!.size())
        self.instantiatePhysicsBody(fromTexture: texture!)

        var costumes = allowCostumes
        self.costume = costumes.remove(at: 0)
        self.costumeQueue = costumes
    }

    /// Initialize the player.
    /// - Parameter texture: A texture to apple to the sprite.
    /// - Parameter color: The color of the sprite.
    /// - Parameter size: The size of the sprite.
    override init(texture: SKTexture?, color: NSColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.instantiatePhysicsBody(fromTexture: texture!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Instantiate this node's physics body.
    /// - Parameter fromTexture: The SKTexture to create the physics body from.
    private func instantiatePhysicsBody(fromTexture: SKTexture) {
        self.physicsBody = SKPhysicsBody(texture: fromTexture, size: fromTexture.size())
        self.physicsBody?.restitution = 0.05
        self.physicsBody?.friction = 0.2
        self.physicsBody?.isDynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.mass = 76.02 / 8
    }

    /// Switch to the next available costume.
    /// - Returns: The next costume the player has switched to.
    public func nextCostume() -> PlayerCostumeType {
        self.costumeQueue.append(self.costume)
        self.costume = self.costumeQueue.remove(at: 0)
        self.texture = SKTexture(imageNamed: "Player (Idle, \(self.costume.rawValue))")
        return self.costume
    }

    /// Move the player by a specific amount.
    ///
    /// Use this when needing to apply an impulse directly on the player to cause a movement to occur. In other instances,
    /// using `move(_ direction: PlayerMoveDirection, unit: CGSize)` is preferred.
    /// - Parameter delta: A vector that represents the delta to move by.
    public func move(_ delta: CGVector) {
        self.physicsBody?.applyImpulse(delta)
    }

    /// Stop the player from moving.
    public func halt() {
        if self.physicsBody?.velocity != .zero {
            self.physicsBody?.velocity = .zero
        }
    }

    /// Move the player in a given direction, relative to the size of the world.
    ///
    /// This method is typically preferred since AI agents can call this method instead of calculating the delta beforehand.
    /// - Parameter direction: The direction the player will move in.
    /// - Parameter unit: The base unit to calculate the movement delta, relatively.
    public func move(_ direction: PlayerMoveDirection, unit: CGSize) {
        var delta = CGVector(dx: 0, dy: 0)
        switch direction {
        case .north:
            delta.dy += unit.height / 2
        case .south:
            delta.dy -= unit.height / 2
        case .east:
            delta.dx += unit.width / 2
        case .west:
            delta.dx -= unit.width / 2
        }
        self.move(delta)

    }

    /// Get the list of costumes from a given ID.
    /// - Parameter id: An integer representing the ID of costumes available.
    public static func getCostumeSet(id: Int) -> [PlayerCostumeType] {
        let defaultSet: [PlayerCostumeType] = [.default, .bird, .flashDrive, .sorceress]
        if id == 0 {
            return [PlayerCostumeType.default]
        } else {
            let upperBound = id + 1
            return defaultSet[..<upperBound].map { costume in costume }
        }
    }
}
