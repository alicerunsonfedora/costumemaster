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

    /// A queue of all available costumes the player can switch to.
    private var costumeQueue: [PlayerCostumeType] = [.bird, .flashDrive, .sorceress]

    /// Whether the player is currently playing an animation.
    private var animating: Bool = false

    // MARK: COMPUTED PROPERTIES

    /// The SKTexture frames that play when a player is changing costumes.
    private var changingFrames: [SKTexture] {
        return animated(fromAtlas: SKTextureAtlas(named: "Player_Change"), reversable: true)
    }

    /// The walk cycle animation when moving south.
    private var forwardWalkCycle: [SKTexture] {
        return animated(fromAtlas: SKTextureAtlas(named: "Player_Forward_\(self.costume.rawValue)"))
    }

    /// The walk cycle animation when moving north.
    private var backwardWalkCycle: [SKTexture] {
        return animated(fromAtlas: SKTextureAtlas(named: "Player_Backward_\(self.costume.rawValue)"))
    }

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

    // MARK: STATIC METHODS

    /// Get the list of costumes from a given ID.
    /// - Parameter id: An integer representing the ID of costumes available.
    // swiftlint:disable:next identifier_name
    public static func getCostumeSet(id: Int) -> [PlayerCostumeType] {
        let defaultSet: [PlayerCostumeType] = [.default, .bird, .flashDrive, .sorceress]
        if id == 0 {
            return [PlayerCostumeType.default]
        } else {
            let upperBound = id + 1
            return defaultSet[..<upperBound].map { costume in costume }
        }
    }

    // MARK: METHODS

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

    /// Animate a costume change.
    /// - Parameter costume: The costume that the player is currently wearing or will switch from.
    private func animateCostumeChange(startingWith costume: PlayerCostumeType) {
        // Halt the player's movement.
        self.halt()

        // Create a ghost sprite for animation purposes.
        let ghostSprite = SKSpriteNode(
            texture: SKTexture(imageNamed: "Player (Idle, \(costume.rawValue))"),
            size: self.size
        )
        ghostSprite.position = self.position
        ghostSprite.zPosition = self.zPosition - 1
        ghostSprite.isHidden = false
        self.parent?.addChild(ghostSprite)

        // Play the animations and remove the ghost from the player's node heirarchy.
        self.animating = true
        self.run(SKAction.sequence([
            SKAction.run {
                ghostSprite.run(SKAction.sequence([
                    SKAction.wait(forDuration: 0.9),
                    SKAction.setTexture(SKTexture(imageNamed: "Player (Idle, \(self.costume.rawValue))")),
                    SKAction.wait(forDuration: 1.1)
                ])
            )},
            SKAction.setTexture(SKTexture(imageNamed: "Player (Idle, \(self.costume.rawValue))")),
            SKAction.animate(with: self.changingFrames, timePerFrame: 0.1, resize: false, restore: true),
            SKAction.run { ghostSprite.removeFromParent() }
        ]))
        self.animating = false
    }

    /// Switch to the previous costume.
    /// - Returns: The previous costume the player is now wearing.
    public func previousCostume() -> PlayerCostumeType {
        // Re-order the queue.
        let currentCostume = self.costume
        self.costume = self.costumeQueue.popLast() ?? .default
        self.costumeQueue.insert(currentCostume, at: 0)

        // Start animating costume changes.
        self.animateCostumeChange(startingWith: currentCostume)

        // Return the costume type.
        return self.costume
    }

    /// Switch to the next available costume.
    /// - Returns: The next costume the player has switched to.
    public func nextCostume() -> PlayerCostumeType {
        // Re-order the queue.
        let currentCostume = self.costume
        self.costume = self.costumeQueue.remove(at: 0)
        self.costumeQueue.append(currentCostume)

        // Start animating costume changes.
        self.animateCostumeChange(startingWith: currentCostume)

        // Return the costume type.
        return self.costume
    }

    // MARK: MOVEMENT METHODS

    /// Move the player by a specific amount.
    ///
    /// Use this when needing to apply an impulse directly on the player to cause a movement to occur. In other
    /// instances, using `move(_ direction: PlayerMoveDirection, unit: CGSize)` is preferred.
    /// Additionally, this method does not handle the proper animation to play when moving in a direction.
    ///
    /// - Parameter delta: A vector that represents the delta to move by.
    public func move(_ delta: CGVector) {
        self.physicsBody?.applyImpulse(delta)
    }

    /// Stop the player from moving and remove all current animations.
    public func halt() {
        if self.physicsBody?.velocity != .zero {
            self.physicsBody?.velocity = .zero
            self.removeAllActions()
            self.animating = false
        }
    }

    /// Move the player in a given direction, relative to the size of the world.
    ///
    /// This method is typically preferred since AI agents can call this method instead of calculating the delta
    /// beforehand. This method also handles any animations that need to be added to make sure the player
    /// has an appropriate animation while walking.
    ///
    /// - Parameter direction: The direction the player will move in.
    /// - Parameter unit: The base unit to calculate the movement delta, relatively.
    public func move(_ direction: PlayerMoveDirection, unit: CGSize) {
        // Create the delta vector and animation
        var delta = CGVector(dx: 0, dy: 0)
        var action: SKAction?

        // Calculate the correct delta based on the direction and generate the proper animation.
        switch direction {
        case .north:
            delta.dy += unit.height / 2
            action = SKAction.animate(
                with: self.backwardWalkCycle,
                timePerFrame: 0.5,
                resize: false,
                restore: true
            )
        case .south:
            delta.dy -= unit.height / 2
            action = SKAction.animate(
                with: self.forwardWalkCycle,
                timePerFrame: 0.5,
                resize: false,
                restore: true
            )
        case .east:
            delta.dx += unit.width / 2
        case .west:
            delta.dx -= unit.width / 2
        }

        // Call the move method with the new delta.
        self.move(delta)

        // If we found an animation, play it and set animating to true.
        if action != nil && !self.animating {
            self.run(SKAction.repeatForever(action!))
            self.animating = true
        }

    }
}
